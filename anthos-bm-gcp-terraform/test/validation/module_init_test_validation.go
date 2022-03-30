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

package validation

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/util"
	"github.com/stretchr/testify/assert"
)

// ValidateVariables validates for correctness of the variables set for the
// `init` module.
func ValidateVariables(goTester *testing.T, tfPlan *util.InitModulePlan) {
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

	// verify plan has resources_path input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.ResourcesPath,
		"Variable not found in plan: resources_path",
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

	// verify plan has init_check_script input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.InitCheckScript,
		"Variable not found in plan: init_check_script",
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

// ValidateVariableValues validates whether the values of the variables set for
// the `init` module matches the ones defined in the test function.
func ValidateVariableValues(goTester *testing.T, initModulePlan *util.InitModulePlan, vars *map[string]interface{}) {
	// verify input variable project_id in plan matches
	assert.Equal(
		goTester,
		(*vars)["project_id"],
		initModulePlan.Variables.ProjectID.Value,
		"Variable does not match in plan: project_id.",
	)

	// verify input variable credentials_file in plan matches
	assert.Equal(
		goTester,
		(*vars)["credentials_file"],
		initModulePlan.Variables.CredentialsFile.Value,
		"Variable does not match in plan: credentials_file.",
	)

	// verify input variable resources_path in plan matches
	assert.Equal(
		goTester,
		(*vars)["resources_path"],
		initModulePlan.Variables.ResourcesPath.Value,
		"Variable does not match in plan: resources_path.",
	)

	// verify input variable zone in plan matches
	assert.Equal(
		goTester,
		(*vars)["zone"],
		initModulePlan.Variables.Zone.Value,
		"Variable does not match in plan: zone.",
	)

	// verify input variable username in plan matches
	assert.Equal(
		goTester,
		(*vars)["username"],
		initModulePlan.Variables.Username.Value,
		"Variable does not match in plan: username.",
	)

	// verify input variable hostname in plan matches
	assert.Equal(
		goTester,
		(*vars)["hostname"],
		initModulePlan.Variables.Hostname.Value,
		"Variable does not match in plan: hostname.",
	)

	// verify input variable publicIp in plan matches
	assert.Equal(
		goTester,
		(*vars)["publicIp"],
		initModulePlan.Variables.PublicIP.Value,
		"Variable does not match in plan: publicIp.",
	)

	// verify input variable init_script in plan matches
	assert.Equal(
		goTester,
		(*vars)["init_script"],
		initModulePlan.Variables.InitScriptPath.Value,
		"Variable does not match in plan: init_script.",
	)

	// verify input variable init_check_script in plan matches
	assert.Equal(
		goTester,
		(*vars)["init_check_script"],
		initModulePlan.Variables.InitCheckScript.Value,
		"Variable does not match in plan: init_check_script.",
	)

	// verify input variable init_logs in plan matches
	assert.Equal(
		goTester,
		(*vars)["init_logs"],
		initModulePlan.Variables.InitLogsFile.Value,
		"Variable does not match in plan: init_logs.",
	)

	// verify input variable init_vars_file in plan matches
	assert.Equal(
		goTester,
		(*vars)["init_vars_file"],
		initModulePlan.Variables.InitScriptVarsFilePath.Value,
		"Variable does not match in plan: init_vars_file.",
	)

	// verify input variable cluster_yaml_path in plan matches
	assert.Equal(
		goTester,
		(*vars)["cluster_yaml_path"],
		initModulePlan.Variables.ClusterYamlPath.Value,
		"Variable does not match in plan: cluster_yaml_path.",
	)

	// verify input variable pub_key_path_template in plan matches
	assert.Equal(
		goTester,
		(*vars)["pub_key_path_template"],
		initModulePlan.Variables.PublicKeyTemplatePath.Value,
		"Variable does not match in plan: pub_key_path_template.",
	)

	// verify input variable priv_key_path_template in plan matches
	assert.Equal(
		goTester,
		(*vars)["priv_key_path_template"],
		initModulePlan.Variables.PrivateKeyTemplatePath.Value,
		"Variable does not match in plan: priv_key_path_template.",
	)
}

// ValidatePlanConfigurations validates for correctness of the terraform actions
// in the terraform plan for the `init` module.
func ValidatePlanConfigurations(goTester *testing.T, initModulePlan *util.InitModulePlan) {
	for rIdx, configResource := range initModulePlan.Configuration.RootModule.Resources {
		if configResource.Type != "null_resource" {
			// we just want to check the configs for the null resource
			continue
		}

		fileProvisioners := 0
		localExecProvisioners := 0
		remoteExecProvisioners := 0
		expectedProvisioners := []string{"file", "remote-exec", "local-exec"}
		for pIdx, provisioner := range configResource.Provisioners {
			assert.Contains(
				goTester,
				expectedProvisioners,
				provisioner.Type,
				fmt.Sprintf("Invalid provisioner for configuration.root_module.resources[%d].provisioners[%d].type", rIdx, pIdx),
			)

			if provisioner.Type == "file" {
				fileProvisioners++
			} else if provisioner.Type == "local-exec" {
				localExecProvisioners++
			} else if provisioner.Type == "remote-exec" {
				remoteExecProvisioners++
			}
		}

		assert.Equal(
			goTester,
			6,
			fileProvisioners,
			fmt.Sprintf("Unexpected number of file provisioners under configuration.root_module.resources[%d].provisioners", rIdx),
		)

		assert.Equal(
			goTester,
			1,
			localExecProvisioners,
			fmt.Sprintf("Unexpected number of local-exec provisioners under configuration.root_module.resources[%d].provisioners", rIdx),
		)

		assert.Equal(
			goTester,
			1,
			remoteExecProvisioners,
			fmt.Sprintf("Unexpected number of remote-exec provisioners under configuration.root_module.resources[%d].provisioners", rIdx),
		)
	}
}
