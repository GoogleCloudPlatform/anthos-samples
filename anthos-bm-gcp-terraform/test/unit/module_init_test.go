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
	"testing"

	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/util"
	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/validation"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// Test for the following:
// 		-	tests if the module has the expected variables defined
//		- tests if the variable in the plan match the ones passed in
//		- tests if the plan has the expected resources and modules
//		- tests if the plan has the correct provisioners for null_resource
func TestUnit_InitModule(goTester *testing.T) {
	goTester.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", "modules/init")
	projectID := "test_project"
	zone := "test_zone"
	credentialsFile := "../test/../path/../credentials_file.json"
	resourcesPath := "../../resources"
	username := "test_username"
	hostname := "test_hostname"
	publicIP := "10.10.10.01"
	initScript := "../test/../path/../init_script.sh"
	initCheckScript := "../test/../path/../run_initialization_checks.sh"
	initLogs := "test_init_log_file.log"
	initVarsFile := "../test/../path/../init_vars_file.var"
	clusterYamlPath := "../test/../path/../test_cluster.yaml"
	pubKeyPathTemplate := "../test/../path/../test_pub_key-%s.pub"
	privKeyPathTemplate := "../test/../path/../test_pub_key-%s.priv"

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfVarsMap := map[string]interface{}{
		"project_id":             projectID,
		"credentials_file":       credentialsFile,
		"resources_path":         resourcesPath,
		"zone":                   zone,
		"username":               username,
		"hostname":               hostname,
		"publicIp":               publicIP,
		"init_script":            initScript,
		"init_check_script":      initCheckScript,
		"init_logs":              initLogs,
		"init_vars_file":         initVarsFile,
		"cluster_yaml_path":      clusterYamlPath,
		"pub_key_path_template":  pubKeyPathTemplate,
		"priv_key_path_template": privKeyPathTemplate,
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

	/**
	 * Pro tip:
	 * Write the json to a file using the util.WriteToFile() method to easily debug
	 * util.WriteToFile(tfPlanJSON, "../../plan.json")
	 */
	var initModulePlan util.InitModulePlan
	err = json.Unmarshal([]byte(tfPlanJSON), &initModulePlan)
	util.LogError(err, "Failed to parse the JSON plan into the ExternalIpPlan struct in unit/module_init.go")

	// validate the plan has the expected variables
	validation.ValidateVariables(goTester, &initModulePlan)
	// validate the plan has the corect values set for the expected variables
	validation.ValidateVariableValues(goTester, &initModulePlan, &tfVarsMap)

	// validate the plan has the expected resources and modules
	// resource type must be one of the following
	resourceTypes := []string{"tls_private_key", "local_file", "null_resource"}
	for idx, rootModule := range initModulePlan.PlannedValues.RootModule.Resources {
		assert.Contains(
			goTester,
			resourceTypes,
			rootModule.Type,
			fmt.Sprintf("Invalid resource type for planned_values.root_module.resources[%d].type", idx),
		)

		if rootModule.Type == "local_file" {
			keyFilenames := []string{
				fmt.Sprintf(pubKeyPathTemplate, hostname),
				fmt.Sprintf(privKeyPathTemplate, hostname),
			}
			assert.Contains(
				goTester,
				keyFilenames,
				rootModule.Values.FileName,
				fmt.Sprintf("Invalid file name for planned_values.root_module.resources[%d].values.filename", idx),
			)
			assert.Equal(
				goTester,
				"0777",
				rootModule.Values.DirPermissions,
				fmt.Sprintf("Invalid directory permissions for planned_values.root_module.resources[%d].values.directory_permission", idx),
			)
			assert.Equal(
				goTester,
				"0600",
				rootModule.Values.FilePermissions,
				fmt.Sprintf("Invalid file permission for planned_values.root_module.resources[%d].values.file_permission", idx),
			)
		} else if rootModule.Type == "tls_private_key" {
			assert.Equal(
				goTester,
				"RSA",
				rootModule.Values.CryptoAlgorithm,
				fmt.Sprintf("Invalid algorithm for planned_values.root_module.resources[%d].values.algorithm", idx),
			)
		}
	}

	// verify that there is only one child module that uses gcloud to add metadata
	assert.Len(
		goTester,
		initModulePlan.PlannedValues.RootModule.ChildModules,
		1,
		fmt.Sprintf("Invalid number of planned_values.root_module.child_modules"),
	)

	// verify that the existing child module name matches
	assert.Equal(
		goTester,
		"module.gcloud_add_ssh_key_metadata",
		initModulePlan.PlannedValues.RootModule.ChildModules[0].ModuleAddress,
		"Unexpected module address for planned_values.root_module.child_modules[0].address",
	)

	// validate that the plan configurations have the correct provisioners for null_resource
	validation.ValidatePlanConfigurations(goTester, &initModulePlan)
}

// Test if the correct default values are being set
func TestUnit_InitModule_DefaultValues(goTester *testing.T) {
	goTester.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", "modules/init")
	projectID := "test_project"
	credentialsFile := "../test/../path/../credentials_file.json"
	hostname := "test_hostname"
	publicIP := "10.10.10.01"
	initVarsFile := "../test/../path/../init_vars_file.var"
	resourcesPath := "../../resources"

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfVarsMap := map[string]interface{}{
		"project_id":       projectID,
		"credentials_file": credentialsFile,
		"resources_path":   resourcesPath,
		"hostname":         hostname,
		"publicIp":         publicIP,
		"init_vars_file":   initVarsFile,
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

	/**
	 * Pro tip:
	 * Write the json to a file using the util.WriteToFile() method to easily debug
	 * util.WriteToFile(tfPlanJSON, "../../plan.json")
	 */
	var initModulePlan util.InitModulePlan
	err = json.Unmarshal([]byte(tfPlanJSON), &initModulePlan)
	util.LogError(err, "Failed to parse the JSON plan into the ExternalIpPlan struct in unit/module_init.go")

	// verify input variable zone in plan matches default value
	assert.Equal(
		goTester,
		"us-central1-a",
		initModulePlan.Variables.Zone.Value,
		"Variable does not match in plan: zone.",
	)

	// verify input variable username in plan matches default value
	assert.Equal(
		goTester,
		"tfadmin",
		initModulePlan.Variables.Username.Value,
		"Variable does not match in plan: username.",
	)

	// verify input variable init_script in plan matches default value
	assert.Equal(
		goTester,
		"../../resources/init_vm.sh",
		initModulePlan.Variables.InitScriptPath.Value,
		"Variable does not match in plan: init_script.",
	)

	// verify input variable init_check_script in plan matches default value
	assert.Equal(
		goTester,
		"../../resources/run_initialization_checks.sh",
		initModulePlan.Variables.InitCheckScript.Value,
		"Variable does not match in plan: init_check_script.",
	)

	// verify input variable init_logs in plan matches default value
	assert.Equal(
		goTester,
		"init.log",
		initModulePlan.Variables.InitLogsFile.Value,
		"Variable does not match in plan: init_logs.",
	)

	// verify input variable cluster_yaml_path in plan matches default value
	assert.Equal(
		goTester,
		"../../resources/.cluster1.yaml",
		initModulePlan.Variables.ClusterYamlPath.Value,
		"Variable does not match in plan: cluster_yaml_path.",
	)

	// verify input variable pub_key_path_template in plan matches default value
	assert.Equal(
		goTester,
		"../../resources/.ssh-key-%s.pub",
		initModulePlan.Variables.PublicKeyTemplatePath.Value,
		"Variable does not match in plan: pub_key_path_template.",
	)

	// verify input variable priv_key_path_template in plan matches default value
	assert.Equal(
		goTester,
		"../../resources/.ssh-key-%s.priv",
		initModulePlan.Variables.PrivateKeyTemplatePath.Value,
		"Variable does not match in plan: priv_key_path_template.",
	)
}
