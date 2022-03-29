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
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/util"
	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/validation"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestUnit_MainScript(goTester *testing.T) {
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

	resourcesPath := "./resources"
	username := "test_username"
	minCPUPlatform := "test_cpu_platform"
	enableNestedVirtualization := "true"
	machineType := "test_machine_type"
	image := "test_image"
	imageProject := "test_image_project"
	imageFamily := "test_image_family"
	bootDiskType := "test_boot_disk_type"
	abmClusterID := "test-abm-cluster-id"
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
		"test_primary_api_1.googleapis.com",
	}
	secondaryApis := []string{
		"test_secondary_api_1.googleapis.com",
		"test_secondary_api_2.googleapis.com",
		"test_secondary_api_3.googleapis.com",
		"test_secondary_api_4.googleapis.com",
	}
	instanceCount := map[string]int{
		"controlplane": 3,
		"worker":       2,
	}
	gpu := map[string]interface{}{
		"count": 3,
		"type":  "google_gpu",
	}

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfVarsMap := map[string]interface{}{
		"project_id":                   projectID,
		"credentials_file":             credentialsFile,
		"resources_path":               resourcesPath,
		"region":                       region,
		"zone":                         zone,
		"username":                     username,
		"min_cpu_platform":             minCPUPlatform,
		"enable_nested_virtualization": enableNestedVirtualization,
		"machine_type":                 machineType,
		"image":                        image,
		"image_project":                imageProject,
		"image_family":                 imageFamily,
		"boot_disk_type":               bootDiskType,
		"boot_disk_size":               bootDiskSize,
		"network":                      network,
		"tags":                         tags,
		"access_scopes":                accessScopes,
		"anthos_service_account_name":  anthosServiceAccountName,
		"primary_apis":                 primaryApis,
		"secondary_apis":               secondaryApis,
		"abm_cluster_id":               abmClusterID,
		"instance_count":               instanceCount,
		"gpu":                          gpu,
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
	util.LogError(err, "Failed to parse the JSON plan into the MainModulePlan struct in unit/module_main.go")
	/**
	 * Pro tip:
	 * Write the json to a file using the util.WriteToFile() method to easily debug
	 * util.WriteToFile(tfPlanJSON, "../../plan.json")
	 */

	// validate the plan has the expected variables
	validation.ValidateVariablesInMain(goTester, &terraformPlan)
	// validate the plan has the corect values set for the expected variables
	validation.ValidateVariableValuesInMain(goTester, &terraformPlan, &tfVarsMap)

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

	_, envVarFilenames := validation.ValidateRootResources(
		goTester, &terraformPlan, instanceCountMapInTest, projectID, abmClusterID)
	// assert that the length of env var file names map is same as
	// controlplane nodes + worker nodes + 1 (admin host) meaning that they
	// are all unique paths
	assert.Len(
		goTester,
		envVarFilenames,
		numberOfHostsForInitialization,
		"There are overlapping file path names for the init.vars file intended for each different hosts",
	)

	var instanceTemplateModules []util.TFModule
	var virtualMachineModules []util.TFModule
	var serviceAccModules []util.TFModule
	var googleAPIsModules []util.TFModule
	var initHostsModules []util.TFModule

	for _, childModule := range terraformPlan.PlannedValues.RootModule.ChildModules {
		moduleAddress := childModule.ModuleAddress
		if strings.HasSuffix(moduleAddress, "instance_template") {
			instanceTemplateModules = append(instanceTemplateModules, childModule)
		} else if strings.HasSuffix(moduleAddress, "vm_hosts") {
			virtualMachineModules = append(virtualMachineModules, childModule)
		} else if strings.HasSuffix(moduleAddress, "service_accounts") {
			serviceAccModules = append(serviceAccModules, childModule)
		} else if strings.Contains(moduleAddress, "google_apis") {
			googleAPIsModules = append(googleAPIsModules, childModule)
		} else if strings.Contains(moduleAddress, "init_hosts") {
			initHostsModules = append(initHostsModules, childModule)
		} else {
			goTester.Errorf("Unexpected module with address [%s] at planned_values.root_module.child_modules", moduleAddress)
		}
	}

	assert.Len(
		goTester,
		instanceTemplateModules,
		1,
		"Unexpected number of child modules with address type instance_template at planned_values.root_module.child_modules",
	)
	assert.Len(
		goTester,
		virtualMachineModules,
		3, // 1 each for admin host, controlplane, worker nodes
		"Unexpected number of child modules with address type vm_hosts at planned_values.root_module.child_modules",
	)
	assert.Len(
		goTester,
		serviceAccModules,
		1,
		"Unexpected number of child modules with address type service_accounts at planned_values.root_module.child_modules",
	)
	assert.Len(
		goTester,
		googleAPIsModules,
		2, // 1 for primary APIs and 1 for secondary APIs
		"Unexpected number of child modules with address type google_apis at planned_values.root_module.child_modules",
	)
	assert.Len(
		goTester,
		initHostsModules,
		numberOfHostsForInitialization,
		"Unexpected number of child modules with address type init_hosts at planned_values.root_module.child_modules",
	)

	// validate the instance template module
	validation.ValidateInstanceTemplateModule(goTester, &instanceTemplateModules[0], &tfVarsMap)
	// validate the virtual machines modules
	validation.ValidateVirtualMachineModules(goTester, &virtualMachineModules, &tfVarsMap)
	// validate the service account module
	validation.ValidateServiceAccModule(goTester, &serviceAccModules[0], &tfVarsMap)
	// validate the google APIs module
	validation.ValidateAPIsMoodule(goTester, &googleAPIsModules, &tfVarsMap)
	// validate the outputs from the script
	validation.ValidateMainOutputs(goTester, terraformPlan.PlannedValues.Outputs, &tfVarsMap)
}

func ValidateVariablesInMain(goTester *testing.T, mainModulePlan *util.MainModulePlan) {
	panic("unimplemented")
}

func TestUnit_MainScript_ValidateDefaults(goTester *testing.T) {

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", ".")
	projectID := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT
	workingDir, err := os.Getwd()
	util.LogError(err, "Failed to read current working directory")
	credentialsFile := fmt.Sprintf("%s/credentials_file.json", workingDir)
	resourcesPath := "./resources"

	tmpFile, err := os.Create(credentialsFile)
	util.LogError(err, fmt.Sprintf("Could not create temporary file at %s", credentialsFile))
	defer tmpFile.Close()
	defer os.Remove(credentialsFile)

	machineType := "test_machine_type"
	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfVarsMap := map[string]interface{}{
		"project_id":       projectID,
		"credentials_file": credentialsFile,
		"resources_path":   resourcesPath,
		"machine_type":     machineType,
		"boot_disk_size":   200,
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
	util.LogError(err, "Failed to parse the JSON plan into the MainModulePlan struct in unit/module_main.go")

	// verify input variable region in plan matches the default value
	assert.Equal(
		goTester,
		"us-central1",
		terraformPlan.Variables.Region.Value,
		"Variable does not match expected default value: region.",
	)

	// verify input variable zone in plan matches the default value
	assert.Equal(
		goTester,
		"us-central1-a",
		terraformPlan.Variables.Zone.Value,
		"Variable does not match expected default value: zone.",
	)

	// verify input variable username in plan matches the default value
	assert.Equal(
		goTester,
		"tfadmin",
		terraformPlan.Variables.Username.Value,
		"Variable does not match expected default value: username.",
	)

	// verify input variable min_cpu_platform in plan matches the default value
	assert.Equal(
		goTester,
		"Intel Haswell",
		terraformPlan.Variables.MinCPUPlatform.Value,
		"Variable does not match expected default value: min_cpu_platform.",
	)

	// verify input variable enable_nested_virtualization in plan matches the default value
	assert.Equal(
		goTester,
		"true",
		terraformPlan.Variables.EnableNestedVirtualization.Value,
		"Variable does not match expected default value: enable_nested_virtualization.",
	)

	// verify input variable image in plan matches the default value
	assert.Equal(
		goTester,
		"ubuntu-2004-focal-v20210429",
		terraformPlan.Variables.Image.Value,
		"Variable does not match expected default value: image.",
	)

	// verify input variable image_project in plan matches the default value
	assert.Equal(
		goTester,
		"ubuntu-os-cloud",
		terraformPlan.Variables.ImageProject.Value,
		"Variable does not match expected default value: image_project.",
	)

	// verify input variable image_family in plan matches the default value
	assert.Equal(
		goTester,
		"ubuntu-2004-lts",
		terraformPlan.Variables.ImageFamily.Value,
		"Variable does not match expected default value: image_family.",
	)

	// verify input variable boot_disk_type in plan matches the default value
	assert.Equal(
		goTester,
		"pd-ssd",
		terraformPlan.Variables.BootDiskType.Value,
		"Variable does not match expected default value: boot_disk_type.",
	)

	// verify input variable network in plan matches the default value
	assert.Equal(
		goTester,
		"default",
		terraformPlan.Variables.Network.Value,
		"Variable does not match expected default value: network.",
	)

	// verify input variable anthos_service_account_name in plan matches the default value
	assert.Equal(
		goTester,
		"baremetal-gcr",
		terraformPlan.Variables.AnthosServiceAccountName.Value,
		"Variable does not match expected default value: anthos_service_account_name.",
	)

	// verify input variable abm_cluster_id in plan matches the default value
	assert.Equal(
		goTester,
		"cluster1",
		terraformPlan.Variables.ABMClusterID.Value,
		"Variable does not match expected default value: abm_cluster_id.",
	)

	defaultTags := []string{"http-server", "https-server"}
	defaultAccessScopes := []string{"cloud-platform"}
	defaultPrimaryApis := []string{
		"cloudresourcemanager.googleapis.com",
	}
	defaultSecondaryApis := []string{
		"anthosgke.googleapis.com",
		"anthos.googleapis.com",
		"container.googleapis.com",
		"gkeconnect.googleapis.com",
		"gkehub.googleapis.com",
		"serviceusage.googleapis.com",
		"stackdriver.googleapis.com",
		"monitoring.googleapis.com",
		"logging.googleapis.com",
		"iam.googleapis.com",
		"compute.googleapis.com",
		"anthosaudit.googleapis.com",
		"opsconfigmonitoring.googleapis.com",
	}

	assert.Len(
		goTester,
		terraformPlan.Variables.Tags.Value,
		len(defaultTags),
		"List variable length does not match the expected default value list length: tags.",
	)
	assert.Len(
		goTester,
		terraformPlan.Variables.AccessScope.Value,
		len(defaultAccessScopes),
		"List variable length does not match the expected default value list length: access_scopes.",
	)
	assert.Len(
		goTester,
		terraformPlan.Variables.PrimaryAPIs.Value,
		len(defaultPrimaryApis),
		"List variable length does not match the expected default value list length: primary_apis.",
	)
	assert.Len(
		goTester,
		terraformPlan.Variables.SecondaryAPIs.Value,
		len(defaultSecondaryApis),
		"List variable length does not match the expected default value list length: secondary_apis.",
	)

	for _, tag := range terraformPlan.Variables.Tags.Value {
		assert.Contains(
			goTester,
			defaultTags,
			tag,
			"Variable does not match any valid default value: tags",
		)
	}
	for _, scope := range terraformPlan.Variables.AccessScope.Value {
		assert.Contains(
			goTester,
			defaultAccessScopes,
			scope,
			"Variable does not match any valid default value: access_scopes.",
		)
	}
	for _, pAPI := range terraformPlan.Variables.PrimaryAPIs.Value {
		assert.Contains(
			goTester,
			defaultPrimaryApis,
			pAPI,
			"Variable does not match any valid default value: primary_apis.",
		)
	}
	for _, sAPI := range terraformPlan.Variables.SecondaryAPIs.Value {
		assert.Contains(
			goTester,
			defaultSecondaryApis,
			sAPI,
			"Variable does not match any valid default value: secondary_apis.",
		)
	}

	defaultNodeCounts := map[string]int{
		"controlplane": 3,
		"worker":       2,
	}
	// verify input variable instance_count.controlplane in plan matches the default value
	assert.Equal(
		goTester,
		defaultNodeCounts["controlplane"],
		terraformPlan.Variables.InstanceCount.Value["controlplane"],
		"Variable does not match expected default value: instance_count.controlplane.",
	)
	// verify input variable instance_count.worker in plan matches the default value
	assert.Equal(
		goTester,
		defaultNodeCounts["worker"],
		terraformPlan.Variables.InstanceCount.Value["worker"],
		"Variable does not match expected default value: instance_count.worker.",
	)

	defaultGpuSetup := util.Gpu{
		Count: 0,
		Type:  "",
	}
	// verify input variable gpu in plan matches the default value
	assert.Equal(
		goTester,
		defaultGpuSetup.Count,
		terraformPlan.Variables.Gpu.Value.Count,
		"Variable does not match expected default value: gpu.count",
	)

	assert.Equal(
		goTester,
		defaultGpuSetup.Type,
		terraformPlan.Variables.Gpu.Value.Type,
		"Variable does not match expected default value: gpu.type",
	)
}

func TestUnit_MainScript_InstallMode(goTester *testing.T) {
	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", ".")
	projectID := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT

	workingDir, err := os.Getwd()
	util.LogError(err, "Failed to read current working directory")
	credentialsFile := fmt.Sprintf("%s/credentials_file.json", workingDir)

	tmpFile, err := os.Create(credentialsFile)
	util.LogError(err, fmt.Sprintf("Could not create temporary file at %s", credentialsFile))
	defer tmpFile.Close()
	defer os.Remove(credentialsFile)

	mode := "install"
	resourcesPath := "./resources"
	bootDiskSize := 175
	instanceCount := map[string]int{
		"controlplane": 3,
		"worker":       2,
	}

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfVarsMap := map[string]interface{}{
		"project_id":       projectID,
		"credentials_file": credentialsFile,
		"mode":             mode,
		"resources_path":   resourcesPath,
		"instance_count":   instanceCount,
		"boot_disk_size":   bootDiskSize,
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
	util.LogError(err, "Failed to parse the JSON plan into the MainModulePlan struct in unit/module_main.go")
	/**
	 * Pro tip:
	 * Write the json to a file using the util.WriteToFile() method to easily debug
	 * util.WriteToFile(tfPlanJSON, "../../plan.json")
	 */

	var installAbmModule []util.TFModule // install_abm

	for _, childModule := range terraformPlan.PlannedValues.RootModule.ChildModules {
		moduleAddress := childModule.ModuleAddress
		if strings.HasSuffix(moduleAddress, "instance_template") ||
			strings.HasSuffix(moduleAddress, "vm_hosts") ||
			strings.HasSuffix(moduleAddress, "service_accounts") ||
			strings.Contains(moduleAddress, "google_apis") ||
			strings.Contains(moduleAddress, "init_hosts") {
			continue
		} else if strings.Contains(moduleAddress, "install_abm") {
			installAbmModule = append(installAbmModule, childModule)
		} else {
			goTester.Errorf("Unexpected module with address [%s] at planned_values.root_module.child_modules", moduleAddress)
		}
	}

	assert.Len(
		goTester,
		installAbmModule,
		1,
		"Unexpected number of child modules with address type install_abm at planned_values.root_module.child_modules",
	)
	// validate the outputs from the script
	validation.ValidateMainOutputsForInstallMode(goTester, terraformPlan.PlannedValues.Outputs, &tfVarsMap)
}
