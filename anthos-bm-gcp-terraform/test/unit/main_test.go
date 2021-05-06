// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package unit

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"os"
	"strconv"
	"testing"

	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/util"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"gopkg.in/yaml.v3"
)

func TestUnit_MainScript(goTester *testing.T) {
	goTester.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", ".")
	projectID := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT
	region := gcp.GetRandomRegion(goTester, projectID, nil, nil)
	zone := gcp.GetRandomZoneForRegion(goTester, projectID, region)

	workingDir, err := os.Getwd()
	util.LogError(err, "Failed to read current working directory")
	credentialsFile := fmt.Sprintf("%s/credentials_file.json", workingDir)

	tmpFile, err := os.Create(credentialsFile)
	util.LogError(err, fmt.Sprintf("Could not create temporary file at %s", credentialsFile))
	defer tmpFile.Close()
	defer os.Remove(credentialsFile)

	username := "test_username"
	minCPUPlatform := "test_cpu_platform"
	machineType := "test_machine_type"
	imageProject := "test_image_project"
	imageFamily := "test_image_family"
	bootDiskType := "test_boot_disk_type"
	abmClusterID := "test_abm_cluster_id"
	network := "test_network"
	bootDiskSize := 175
	anthosServiceAccountName := gcp.RandomValidGcpName()
	tags := []string{
		"test_tag_1",
		"test_tag_2",
	}
	accessScopes := []string{
		"test_scope_1",
		"test_scope_2",
	}
	primaryApis := []string{
		"test_primary_api_1",
		"test_primary_api_2",
	}
	secondaryApis := []string{
		"test_secondary_api_1",
		"test_secondary_api_2",
		"test_secondary_api_3",
	}
	instanceCount := map[string]int{
		"controlplane": 3,
		"worker":       2,
	}

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfVarsMap := map[string]interface{}{
		"project_id":                  projectID,
		"credentials_file":            credentialsFile,
		"region":                      region,
		"zone":                        zone,
		"username":                    username,
		"min_cpu_platform":            minCPUPlatform,
		"machine_type":                machineType,
		"image_project":               imageProject,
		"image_family":                imageFamily,
		"boot_disk_type":              bootDiskType,
		"boot_disk_size":              bootDiskSize,
		"network":                     network,
		"tags":                        tags,
		"access_scopes":               accessScopes,
		"anthos_service_account_name": anthosServiceAccountName,
		"primary_apis":                primaryApis,
		"secondary_apis":              secondaryApis,
		"abm_cluster_id":              abmClusterID,
		"instance_count":              instanceCount,
	}

	tfOptions := terraform.WithDefaultRetryableErrors(goTester, &terraform.Options{
		TerraformDir: moduleDir,
		// Variables to pass to our Terraform code using -var options
		Vars:         tfVarsMap,
		PlanFilePath: tfPlanOutput,
	})

	// Terraform init and plan only
	terraform.Init(goTester, tfOptions)
	terraform.RunTerraformCommand(
		goTester,
		tfOptions,
		terraform.FormatArgs(tfOptions, "plan", tfPlanOutputArg)...,
	)
	tfPlanJSON, err := terraform.ShowE(goTester, tfOptions)
	util.LogError(err, fmt.Sprintf("Failed to parse the plan file %s into JSON format", tfPlanOutput))

	var terraformPlan util.MainModulePlan
	err = json.Unmarshal([]byte(tfPlanJSON), &terraformPlan)
	util.LogError(err, "Failed to parse the JSON plan into the ExternalIpPlan struct in unit/module_external_ip.go")
	/**
	 * Pro tip:
	 * Write the json to a file using the util.WriteToFile() method to easily debug
	 * util.WriteToFile(tfPlanJSON, "../../plan.json")
	 */

	// validate the plan has the expected variables
	validateVariablesInMain(goTester, &terraformPlan)
	// validate the plan has the corect values set for the expected variables
	validateVariableValuesInMain(goTester, &terraformPlan, &tfVarsMap)

	// validate the plan has the expected resources and modules
	instanceCountMapInTest := tfVarsMap["instance_count"].(map[string]int)
	numberOfHostsForInitialization :=
		instanceCountMapInTest["controlplane"] + instanceCountMapInTest["worker"] + 1 // 1 for the admin vm
	rootResourceCount := numberOfHostsForInitialization + 1 // 1 for the cluster_yaml created from template
	assert.Len(
		goTester,
		terraformPlan.PlannedValues.RootModule.Resources,
		rootResourceCount,
		fmt.Sprintf("Invalid resource count in the root module of the plan at planned_values.root_module.resources"),
	)
	for idx, rootResource := range terraformPlan.PlannedValues.RootModule.Resources {
		assert.Equal(
			goTester,
			"local_file",
			rootResource.Type,
			fmt.Sprintf("Invalid resource type for planned_values.root_module.resources[%d]", idx),
		)

		if rootResource.Name == "cluster_yaml" {
			validateYaml(goTester, instanceCountMapInTest, rootResource, projectID, abmClusterID)
		} else {

		}
	}
}

func validateYaml(
	goTester *testing.T, instanceCountMapInTest map[string]int,
	rootResource util.TFResource, projectID, abmClusterID string) {

	allIps := make(map[string]interface{})
	validNamespaceName := fmt.Sprintf("%s-ns", abmClusterID)
	validRsourceKinds := []string{"Namespace", "NodePool", "Cluster"}
	fileContents := rootResource.Values.Content
	fileReader := bytes.NewReader([]byte(fileContents))
	decodedYaml := yaml.NewDecoder(fileReader)
	for {
		newYamlDefinition := new(util.ClusterYaml)
		err := decodedYaml.Decode(&newYamlDefinition)
		if errors.Is(err, io.EOF) {
			break
		}
		util.LogError(err, "Failed to decode yaml definiton")
		if newYamlDefinition.Kind == nil {
			// there could be one definition without a resource kind;
			// this holds just path defniitions to key files
			continue
		}
		assert.Contains(
			goTester,
			validRsourceKinds,
			*newYamlDefinition.Kind,
			"Invalid resource kind in the cluster_yaml file",
		)

		if *newYamlDefinition.Kind == "Namespace" {
			assert.Equal(
				goTester,
				validNamespaceName,
				newYamlDefinition.Metadata.Name,
				"Invalid metadate name for resource kind Namespace in the cluster_yaml file",
			)
		} else if *newYamlDefinition.Kind == "NodePool" {
			assert.NotNil(
				goTester,
				newYamlDefinition.Spec,
				"Resource kind NodePool is excpected to have a spec definition in the cluster_yaml file",
			)
			assert.Equal(
				goTester,
				validNamespaceName,
				newYamlDefinition.Metadata.Namespace,
				"Invalid metadate namespace for resource kind NodePool in the cluster_yaml file",
			)
			assert.Equal(
				goTester,
				abmClusterID,
				*newYamlDefinition.Spec.ClusterName,
				"Invalid spec clusterName for resource kind NodePool in the cluster_yaml file",
			)
			assert.NotNil(
				goTester,
				newYamlDefinition.Spec.Nodes,
				"Resource kind NodePool is expected to define spec.nodes in the cluster_yaml file",
			)
			assert.Len(
				goTester,
				*newYamlDefinition.Spec.Nodes,
				instanceCountMapInTest["worker"],
				"Invalid number of nodes for spec.nodes in resource kind NodePool in the cluster_yaml file",
			)
			for idx, ip := range *newYamlDefinition.Spec.Nodes {
				assert.True(
					goTester,
					net.ParseIP(ip.Address) != nil, // ensure the IP address is valid
					fmt.Sprintf("Invalid IP address format for spec.nodes[%d].address in resource kind NodePool in the cluster_yaml file", idx),
				)
				allIps[ip.Address] = nil
			}
		} else {
			assert.NotNil(
				goTester,
				newYamlDefinition.Spec,
				"Resource kind Cluster is excpected to have a spec definition in the cluster_yaml file",
			)
			assert.NotNil(
				goTester,
				newYamlDefinition.Spec.GkeConnect,
				"Resource kind Cluster is excpected to have a spec.gkeConnect definition in the cluster_yaml file",
			)
			assert.NotNil(
				goTester,
				newYamlDefinition.Spec.ClusterOperations,
				"Resource kind Cluster is excpected to have a spec.clusterOperations definition in the cluster_yaml file",
			)
			assert.NotNil(
				goTester,
				newYamlDefinition.Spec.ControlPlane,
				"Resource kind Cluster is excpected to have a spec.controlPlane definition in the cluster_yaml file",
			)
			assert.NotNil(
				goTester,
				newYamlDefinition.Spec.ControlPlane.NodePoolSpec,
				"Resource kind Cluster is excpected to have a spec.controlPlane.nodePoolSpec definition in the cluster_yaml file",
			)
			assert.NotNil(
				goTester,
				newYamlDefinition.Spec.ControlPlane.NodePoolSpec.Nodes,
				"Resource kind Cluster is excpected to have a spec.controlPlane.nodePoolSpec.nodes definition in the cluster_yaml file",
			)
			assert.Equal(
				goTester,
				projectID,
				newYamlDefinition.Spec.GkeConnect.ProjectID,
				"Invalid value for spec.gkeConnect.ProjectID for resource kind Cluster in the cluster_yaml file",
			)
			assert.Equal(
				goTester,
				projectID,
				newYamlDefinition.Spec.ClusterOperations.ProjectID,
				"Invalid value for spec.clusterOperations.ProjectID for resource kind Cluster in the cluster_yaml file",
			)
			assert.Equal(
				goTester,
				abmClusterID,
				newYamlDefinition.Spec.ControlPlane.NodePoolSpec.ClusterName,
				"Invalid value for spec.controlPlane.nodePoolSpec.clusterName for resource kind Cluster in the cluster_yaml file",
			)
			assert.Len(
				goTester,
				*newYamlDefinition.Spec.ControlPlane.NodePoolSpec.Nodes,
				instanceCountMapInTest["controlplane"],
				"Invalid number of nodes for spec.controlPlane.nodePoolSpec.nodes in resource kind Cluster in the cluster_yaml file",
			)
			for idx, ip := range *newYamlDefinition.Spec.ControlPlane.NodePoolSpec.Nodes {
				assert.True(
					goTester,
					net.ParseIP(ip.Address) != nil, // ensure the IP address is valid
					fmt.Sprintf("Invalid IP address format for spec.controlPlane.nodePoolSpec.nodes[%d].address in resource kind Cluster in the cluster_yaml file", idx),
				)
				allIps[ip.Address] = nil
			}
		}
	}

	assert.Len(
		goTester,
		allIps,
		instanceCountMapInTest["worker"]+instanceCountMapInTest["controlplane"],
		"There are overlapping IP addresses in the generated IPs for control plane and worker nodes",
	)
}

func validateVariablesInMain(goTester *testing.T, tfPlan *util.MainModulePlan) {
	// verify plan has project_id input variable
	hasVar := assert.NotNil(
		goTester,
		tfPlan.Variables.ProjectID,
		"Variable not found in plan: project_id",
	)
	util.ExitIf(hasVar, false)

	// verify plan has region input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Region,
		"Variable not found in plan: region",
	)
	util.ExitIf(hasVar, false)

	// verify plan has zone input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Zone,
		"Variable not found in plan: zone",
	)
	util.ExitIf(hasVar, false)

	// verify plan has network input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Network,
		"Variable not found in plan: network",
	)
	util.ExitIf(hasVar, false)

	// verify plan has username input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Username,
		"Variable not found in plan: username",
	)
	util.ExitIf(hasVar, false)

	// verify plan has abm_cluster_id input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.ABMClusterID,
		"Variable not found in plan: abm_cluster_id",
	)
	util.ExitIf(hasVar, false)

	// verify plan has anthos_service_account_name input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.AnthosServiceAccountName,
		"Variable not found in plan: anthos_service_account_name",
	)
	util.ExitIf(hasVar, false)

	// verify plan has boot_disk_size input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.BootDiskSize,
		"Variable not found in plan: boot_disk_size",
	)
	util.ExitIf(hasVar, false)

	// verify plan has boot_disk_type input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.BootDiskType,
		"Variable not found in plan: boot_disk_type",
	)
	util.ExitIf(hasVar, false)

	// verify plan has credentials_file input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.CrendetialsFile,
		"Variable not found in plan: credentials_file",
	)
	util.ExitIf(hasVar, false)

	// verify plan has image_family input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.ImageFamily,
		"Variable not found in plan: image_family",
	)
	util.ExitIf(hasVar, false)

	// verify plan has image_project input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.ImageProject,
		"Variable not found in plan: image_project",
	)
	util.ExitIf(hasVar, false)

	// verify plan has machine_type input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.MachineType,
		"Variable not found in plan: machine_type",
	)
	util.ExitIf(hasVar, false)

	// verify plan has min_cpu_platform input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.MinCPUPlatform,
		"Variable not found in plan: min_cpu_platform",
	)
	util.ExitIf(hasVar, false)

	// verify plan has tags input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Tags,
		"Variable not found in plan: tags",
	)
	util.ExitIf(hasVar, false)

	// verify plan has tags input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Tags,
		"Variable not found in plan: tags",
	)
	util.ExitIf(hasVar, false)

	// verify plan has access_scopes input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.AccessScope,
		"Variable not found in plan: access_scopes",
	)
	util.ExitIf(hasVar, false)

	// verify plan has primary_apis input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.PrimaryAPIs,
		"Variable not found in plan: primary_apis",
	)
	util.ExitIf(hasVar, false)

	// verify plan has secondary_apis input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.SecondaryAPIs,
		"Variable not found in plan: secondary_apis",
	)
	util.ExitIf(hasVar, false)

	// verify plan has instance_count input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.InstanceCount,
		"Variable not found in plan: instance_count",
	)
	util.ExitIf(hasVar, false)
}

func validateVariableValuesInMain(goTester *testing.T, tfPlan *util.MainModulePlan, vars *map[string]interface{}) {
	// verify input variable project_id in plan matches
	assert.Equal(
		goTester,
		(*vars)["project_id"],
		tfPlan.Variables.ProjectID.Value,
		"Variable does not match in plan: project_id.",
	)

	// verify input variable credentials_file in plan matches
	assert.Equal(
		goTester,
		(*vars)["region"],
		tfPlan.Variables.Region.Value,
		"Variable does not match in plan: credentials_file.",
	)

	// verify input variable zone in plan matches
	assert.Equal(
		goTester,
		(*vars)["zone"],
		tfPlan.Variables.Zone.Value,
		"Variable does not match in plan: zone.",
	)

	// verify input variable network in plan matches
	assert.Equal(
		goTester,
		(*vars)["network"],
		tfPlan.Variables.Network.Value,
		"Variable does not match in plan: network.",
	)

	// verify input variable username in plan matches
	assert.Equal(
		goTester,
		(*vars)["username"],
		tfPlan.Variables.Username.Value,
		"Variable does not match in plan: username.",
	)

	// verify input variable abm_cluster_id in plan matches
	assert.Equal(
		goTester,
		(*vars)["abm_cluster_id"],
		tfPlan.Variables.ABMClusterID.Value,
		"Variable does not match in plan: abm_cluster_id.",
	)

	// verify input variable anthos_service_account_name in plan matches
	assert.Equal(
		goTester,
		(*vars)["anthos_service_account_name"],
		tfPlan.Variables.AnthosServiceAccountName.Value,
		"Variable does not match in plan: anthos_service_account_name.",
	)

	// verify input variable boot_disk_size in plan matches
	planValue, _ := strconv.Atoi(tfPlan.Variables.BootDiskSize.Value)
	assert.Equal(
		goTester,
		(*vars)["boot_disk_size"],
		planValue,
		"Variable does not match in plan: boot_disk_size.",
	)

	// verify input variable boot_disk_type in plan matches
	assert.Equal(
		goTester,
		(*vars)["boot_disk_type"],
		tfPlan.Variables.BootDiskType.Value,
		"Variable does not match in plan: boot_disk_type.",
	)

	// verify input variable credentials_file in plan matches
	assert.Equal(
		goTester,
		(*vars)["credentials_file"],
		tfPlan.Variables.CrendetialsFile.Value,
		"Variable does not match in plan: credentials_file.",
	)

	// verify input variable image_family in plan matches
	assert.Equal(
		goTester,
		(*vars)["image_family"],
		tfPlan.Variables.ImageFamily.Value,
		"Variable does not match in plan: image_family.",
	)

	// verify input variable image_project in plan matches
	assert.Equal(
		goTester,
		(*vars)["image_project"],
		tfPlan.Variables.ImageProject.Value,
		"Variable does not match in plan: image_project.",
	)

	// verify input variable machine_type in plan matches
	assert.Equal(
		goTester,
		(*vars)["machine_type"],
		tfPlan.Variables.MachineType.Value,
		"Variable does not match in plan: machine_type.",
	)

	// verify input variable min_cpu_platform in plan matches
	assert.Equal(
		goTester,
		(*vars)["min_cpu_platform"],
		tfPlan.Variables.MinCPUPlatform.Value,
		"Variable does not match in plan: min_cpu_platform.",
	)

	// verify input variable tags in plan matches every tag in the list
	for _, tag := range tfPlan.Variables.Tags.Value {
		assert.Contains(
			goTester,
			(*vars)["tags"],
			tag,
			"Variable does not match in plan: tags.",
		)
	}

	// verify input variable access_scopes in plan matches every access_scope in the list
	for _, accessScope := range tfPlan.Variables.AccessScope.Value {
		assert.Contains(
			goTester,
			(*vars)["access_scopes"],
			accessScope,
			"Variable does not match in plan: access_scopes.",
		)
	}

	// verify input variable primary_apis in plan matches every api in the list
	for _, api := range tfPlan.Variables.PrimaryAPIs.Value {
		assert.Contains(
			goTester,
			(*vars)["primary_apis"],
			api,
			"Variable does not match in plan: primary_apis.",
		)
	}

	// verify input variable secondary_apis in plan matches every api in the list
	for _, api := range tfPlan.Variables.SecondaryAPIs.Value {
		assert.Contains(
			goTester,
			(*vars)["secondary_apis"],
			api,
			"Variable does not match in plan: secondary_apis.",
		)
	}

	// verify input variable instance_count in plan matches required types of instances
	instanceCountMapInTest := (*vars)["instance_count"].(map[string]int)
	instanceCountInPlan := tfPlan.Variables.InstanceCount.Value
	validNames := []string{}
	for k := range instanceCountMapInTest {
		validNames = append(validNames, k)
	}
	for name, vmCount := range instanceCountInPlan {
		assert.Contains(
			goTester,
			validNames,
			name,
			"Variable does not match in plan: instance_count.",
		)

		assert.Equal(
			goTester,
			instanceCountMapInTest[name],
			vmCount,
			fmt.Sprintf("Variable does not match in plan: instance_count for %s.", name),
		)
	}
}
