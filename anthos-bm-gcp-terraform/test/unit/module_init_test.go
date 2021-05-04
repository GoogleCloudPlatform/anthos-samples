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
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestUnit_InitModule(goTester *testing.T) {
	goTester.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", "modules/init")
	projectID := "test_project"
	zone := "test_zone"
	credentialsFile := "../test/../path/../credentials_file.json"
	username := "test_username"
	hostname := "test_hostname"
	publicIP := "10.10.10.01"
	initScript := "../test/../path/../init_script.sh"
	preflightScript := "../test/../path/../preflight_script.sh"
	initLogs := "test_init_log_file.log"
	initVarsFile := "../test/../path/../init_vars_file.var"
	clusterYamlPath := "../test/../path/../test_cluster.yaml"
	pubKeyPathTemplate := "../test/../path/../test_pub_key-%s.pub"
	privKeyPathTemplate := "../test/../path/../test_pub_key-%s.priv"

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfOptions := terraform.WithDefaultRetryableErrors(goTester, &terraform.Options{
		TerraformDir: moduleDir,
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"project_id":             projectID,
			"credentials_file":       credentialsFile,
			"zone":                   zone,
			"username":               username,
			"hostname":               hostname,
			"publicIp":               publicIP,
			"init_script":            initScript,
			"preflight_script":       preflightScript,
			"init_logs":              initLogs,
			"init_vars_file":         initVarsFile,
			"cluster_yaml_path":      clusterYamlPath,
			"pub_key_path_template":  pubKeyPathTemplate,
			"priv_key_path_template": privKeyPathTemplate,
		},
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
	util.LogError(err, "Failed to parse the JSON plan into the ExternalIpPlan struct in unit/module_external_ip.go")

	// TODO: test variables count and names
	// TODO: test variable format (IP address)
	// TODO: test default variables
	// TODO: test locals variables and there validity
	// TODO: test resources that are planned

	// validate the plan has the expected variables
	validateVariables(goTester, &initModulePlan)

	// verify input variable project_id in plan matches
	assert.Equal(
		goTester,
		projectID,
		initModulePlan.Variables.ProjectID.Value,
		"Variable does not match in plan: project_id.",
	)

	// verify input variable credentials_file in plan matches
	assert.Equal(
		goTester,
		credentialsFile,
		initModulePlan.Variables.CredentialsFile.Value,
		"Variable does not match in plan: credentials_file.",
	)

	// verify input variable zone in plan matches
	assert.Equal(
		goTester,
		zone,
		initModulePlan.Variables.Zone.Value,
		"Variable does not match in plan: zone.",
	)

	// verify input variable username in plan matches
	assert.Equal(
		goTester,
		username,
		initModulePlan.Variables.Username.Value,
		"Variable does not match in plan: username.",
	)

	// verify input variable hostname in plan matches
	assert.Equal(
		goTester,
		hostname,
		initModulePlan.Variables.Hostname.Value,
		"Variable does not match in plan: hostname.",
	)

	// verify input variable publicIp in plan matches
	assert.Equal(
		goTester,
		publicIP,
		initModulePlan.Variables.PublicIP.Value,
		"Variable does not match in plan: publicIp.",
	)

	// verify input variable init_script in plan matches
	assert.Equal(
		goTester,
		initScript,
		initModulePlan.Variables.InitScriptPath.Value,
		"Variable does not match in plan: init_script.",
	)

	// verify input variable preflight_script in plan matches
	assert.Equal(
		goTester,
		preflightScript,
		initModulePlan.Variables.PreflightsScript.Value,
		"Variable does not match in plan: preflight_script.",
	)

	// verify input variable init_logs in plan matches
	assert.Equal(
		goTester,
		initLogs,
		initModulePlan.Variables.InitLogsFile.Value,
		"Variable does not match in plan: init_logs.",
	)

	// verify input variable init_vars_file in plan matches
	assert.Equal(
		goTester,
		initVarsFile,
		initModulePlan.Variables.InitScriptVarsFilePath.Value,
		"Variable does not match in plan: init_vars_file.",
	)

	// verify input variable cluster_yaml_path in plan matches
	assert.Equal(
		goTester,
		clusterYamlPath,
		initModulePlan.Variables.ClusterYamlPath.Value,
		"Variable does not match in plan: cluster_yaml_path.",
	)

	// verify input variable pub_key_path_template in plan matches
	assert.Equal(
		goTester,
		pubKeyPathTemplate,
		initModulePlan.Variables.PublicKeyTemplatePath.Value,
		"Variable does not match in plan: pub_key_path_template.",
	)

	// verify input variable priv_key_path_template in plan matches
	assert.Equal(
		goTester,
		privKeyPathTemplate,
		initModulePlan.Variables.PrivateKeyTemplatePath.Value,
		"Variable does not match in plan: priv_key_path_template.",
	)
}

func validateVariables(goTester *testing.T, tfPlan *util.InitModulePlan) {
	// verify plan has project_id input variable
	hasVar := assert.NotNil(
		goTester,
		tfPlan.Variables.ProjectID,
		"Variable not found in plan: project_id",
	)
	util.ExitIf(hasVar, false)

	// verify plan has credentials_file input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.CredentialsFile,
		"Variable not found in plan: credentials_file",
	)
	util.ExitIf(hasVar, false)

	// verify plan has zone input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Zone,
		"Variable not found in plan: zone",
	)
	util.ExitIf(hasVar, false)

	// verify plan has username input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Username,
		"Variable not found in plan: username",
	)
	util.ExitIf(hasVar, false)

	// verify plan has hostname input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Hostname,
		"Variable not found in plan: hostname",
	)
	util.ExitIf(hasVar, false)

	// verify plan has publicIp input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.PublicIP,
		"Variable not found in plan: publicIp",
	)
	util.ExitIf(hasVar, false)

	// verify plan has init_script input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.InitScriptPath,
		"Variable not found in plan: init_script",
	)
	util.ExitIf(hasVar, false)

	// verify plan has preflight_script input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.PreflightsScript,
		"Variable not found in plan: preflight_script",
	)
	util.ExitIf(hasVar, false)

	// verify plan has init_logs input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.InitLogsFile,
		"Variable not found in plan: init_logs",
	)
	util.ExitIf(hasVar, false)

	// verify plan has init_vars_file input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.InitScriptVarsFilePath,
		"Variable not found in plan: init_vars_file",
	)
	util.ExitIf(hasVar, false)

	// verify plan has cluster_yaml_path input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.ClusterYamlPath,
		"Variable not found in plan: cluster_yaml_path",
	)
	util.ExitIf(hasVar, false)

	// verify plan has pub_key_path_template input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.PublicKeyTemplatePath,
		"Variable not found in plan: pub_key_path_template",
	)
	util.ExitIf(hasVar, false)

	// verify plan has priv_key_path_template input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.PrivateKeyTemplatePath,
		"Variable not found in plan: priv_key_path_template",
	)
	util.ExitIf(hasVar, false)
}
