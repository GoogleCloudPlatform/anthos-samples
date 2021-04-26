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
	"testing"

	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/util"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestUnit_InitModule(goTester *testing.T) {
	goTester.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", "modules/init")
	projectId := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT
	credentialsFile := os.Getenv("GOOGLE_CLOUD_PROJECT")
	zone := gcp.GetRandomZone(goTester, projectId, nil, nil, nil)
	username := "test_username"
	hostname := "test_hostname"
	ipAddress := "10.10.10.01"
	init_script := "../test/../path/../init_script.sh"
	preflight_script := "../test/../path/../preflight_script.sh"
	init_logs := "test_init_log_file.log"
	init_vars_file := "../test/../path/../init_vars_file.var"
	cluster_yaml_path := "../test/../path/../test_cluster.yaml"
	pub_key_path_template := "../test/../path/../test_pub_key-%s.pub"
	priv_key_path_template := "../test/../path/../test_pub_key-%s.priv"

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfOptions := terraform.WithDefaultRetryableErrors(goTester, &terraform.Options{
		TerraformDir: moduleDir,
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"project_id":             projectId,
			"credentials_file":       credentialsFile,
			"zone":                   zone,
			"username":               username,
			"hostname":               hostname,
			"publicIp":               ipAddress,
			"init_script":            init_script,
			"preflight_script":       preflight_script,
			"init_logs":              init_logs,
			"init_vars_file":         init_vars_file,
			"cluster_yaml_path":      cluster_yaml_path,
			"pub_key_path_template":  pub_key_path_template,
			"priv_key_path_template": priv_key_path_template,
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

	validateVariables(goTester, &initModulePlan)

}

func validateVariables(goTester *testing.T, tfPlan *util.InitModulePlan) {
	// verify plan has region input variable
	hasVar := assert.NotNil(
		goTester,
		tfPlan.Variables.ProjectId,
		"Variable not found in plan: project_id",
	)
	util.ExitIf(hasVar, false)
}
