// Copyright 2022 Google LLC
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

func TestUnit_MainScript_InstallMode(goTester *testing.T) {
	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", ".")
	projectID := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT

	workingDir, err := os.Getwd()
	util.LogError(err, "Failed to read current working directory")
	credentialsFile := fmt.Sprintf("%s/credentials_file.json", workingDir)

	dummyCredentials := `
{
	"type": "service_account",
	"project_id": "temp-proj",
	"private_key_id": "pkey-id",
	"private_key": "-----BEGIN PRIVATE KEY-----\npkey\n-----END PRIVATE KEY-----\n",
	"client_email": "temp-proj@temp-proj.iam.gserviceaccount.com",
	"client_id": "12344321",
	"auth_uri": "https://accounts.google.com/o/oauth2/auth",
	"token_uri": "https://oauth2.googleapis.com/token",
	"auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
	"client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/temp-proj@temp-proj.iam.gserviceaccount.com"
}
	`
	if _, err := os.Stat(credentialsFile); err == nil {
		os.Remove(credentialsFile)
	}
	tmpFile, err := os.Create(credentialsFile)
	util.LogError(err, fmt.Sprintf("Could not create temporary file at %s", credentialsFile))
	defer tmpFile.Close()
	defer os.Remove(credentialsFile)

	_, err = tmpFile.WriteString(dummyCredentials)
	util.LogError(err, fmt.Sprintf("Could not write to temporary file at %s", credentialsFile))
	err = tmpFile.Sync()
	util.LogError(err, fmt.Sprintf("Could not sync to temporary file at %s", credentialsFile))

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
			strings.HasSuffix(moduleAddress, "instance_template_worker") ||
			strings.HasSuffix(moduleAddress, "vm_hosts") ||
			strings.HasSuffix(moduleAddress, "service_accounts") ||
			strings.Contains(moduleAddress, "google_apis") ||
			strings.Contains(moduleAddress, "init_hosts") ||
			strings.Contains(moduleAddress, "gke_hub_membership") {
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

func TestUnit_MainScript_ManualLB(goTester *testing.T) {
	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", ".")
	projectID := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT

	workingDir, err := os.Getwd()
	util.LogError(err, "Failed to read current working directory")
	credentialsFile := fmt.Sprintf("%s/credentials_file.json", workingDir)

	dummyCredentials := `
	{
		"type": "service_account",
		"project_id": "temp-proj",
		"private_key_id": "pkey-id",
		"private_key": "-----BEGIN PRIVATE KEY-----\npkey\n-----END PRIVATE KEY-----\n",
		"client_email": "temp-proj@temp-proj.iam.gserviceaccount.com",
		"client_id": "12344321",
		"auth_uri": "https://accounts.google.com/o/oauth2/auth",
		"token_uri": "https://oauth2.googleapis.com/token",
		"auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
		"client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/temp-proj@temp-proj.iam.gserviceaccount.com"
	}
		`
	if _, err := os.Stat(credentialsFile); err == nil {
		os.Remove(credentialsFile)
	}
	tmpFile, err := os.Create(credentialsFile)
	util.LogError(err, fmt.Sprintf("Could not create temporary file at %s", credentialsFile))
	defer tmpFile.Close()
	defer os.Remove(credentialsFile)

	_, err = tmpFile.WriteString(dummyCredentials)
	util.LogError(err, fmt.Sprintf("Could not write to temporary file at %s", credentialsFile))
	err = tmpFile.Sync()
	util.LogError(err, fmt.Sprintf("Could not sync to temporary file at %s", credentialsFile))

	bootDiskSize := 175
	abmClusterID := "test-abm-cluster-id"
	resourcesPath := "./resources"
	instanceCount := map[string]int{
		"controlplane": 3,
		"worker":       2,
	}
	scriptMode := "manuallb"

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	// Variables to pass to our Terraform code using -var options
	tfVarsMap := map[string]interface{}{
		"project_id":       projectID,
		"credentials_file": credentialsFile,
		"resources_path":   resourcesPath,
		"boot_disk_size":   bootDiskSize,
		"abm_cluster_id":   abmClusterID,
		"instance_count":   instanceCount,
		"mode":             scriptMode,
	}

	tfOptions := terraform.WithDefaultRetryableErrors(goTester, &terraform.Options{
		TerraformDir: moduleDir,
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

	// validate the plan has the expected variable for 'mode'
	assert.NotNil(
		goTester,
		terraformPlan.Variables.Mode,
		"Variable not found in plan: mode",
	)
	// validate the plan has 'manuallb' set for mode
	assert.Equal(
		goTester,
		terraformPlan.Variables.Mode.Value,
		scriptMode,
		fmt.Sprintf("Variable 'mode' is the plan is not set to: %s", scriptMode),
	)

	foundYamlResource := false
	for _, rootResource := range terraformPlan.PlannedValues.RootModule.Resources {
		if rootResource.Name == "cluster_yaml_manuallb" {
			foundYamlResource = true
			break
		}
	}
	assert.True(
		goTester,
		foundYamlResource,
		"There was no resource for the ABM cluster yaml. Hence could not validate it",
	)

	var ingressLBModule []util.TFModule
	var controlplaneLBModule []util.TFModule
	var installAbmModule []util.TFModule // install_abm

	for _, childModule := range terraformPlan.PlannedValues.RootModule.ChildModules {
		moduleAddress := childModule.ModuleAddress
		if strings.HasSuffix(moduleAddress, "instance_template") ||
			strings.HasSuffix(moduleAddress, "instance_template_worker") ||
			strings.HasSuffix(moduleAddress, "vm_hosts") ||
			strings.HasSuffix(moduleAddress, "service_accounts") ||
			strings.Contains(moduleAddress, "google_apis") ||
			strings.Contains(moduleAddress, "init_hosts") ||
			strings.Contains(moduleAddress, "gke_hub_membership") {
			continue
		} else if strings.HasSuffix(moduleAddress, "configure_ingress_lb[0]") {
			ingressLBModule = append(ingressLBModule, childModule)
		} else if strings.HasSuffix(moduleAddress, "configure_controlplane_lb[0]") {
			controlplaneLBModule = append(controlplaneLBModule, childModule)
		} else if strings.Contains(moduleAddress, "install_abm") {
			installAbmModule = append(installAbmModule, childModule)
		} else {
			goTester.Errorf("Unexpected module with address [%s] at planned_values.root_module.child_modules", moduleAddress)
		}
	}

	assert.Len(
		goTester,
		ingressLBModule,
		1,
		"Unexpected number of child modules with address type configure_ingress_lb at planned_values.root_module.child_modules",
	)
	assert.Len(
		goTester,
		controlplaneLBModule,
		1,
		"Unexpected number of child modules with address type configure_controlplane_lb at planned_values.root_module.child_modules",
	)
	assert.Len(
		goTester,
		installAbmModule,
		1,
		"Unexpected number of child modules with address type install_abm at planned_values.root_module.child_modules",
	)

	// validate the outputs from the script
	validation.ValidateMainOutputsForManualMode(goTester, terraformPlan.PlannedValues.Outputs, &tfVarsMap)
}
