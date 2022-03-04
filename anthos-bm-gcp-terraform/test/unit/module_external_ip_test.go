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
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestUnit_ExternalIpsModule(goTester *testing.T) {
	goTester.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", "modules/external-ip")
	region := "test_region"
	randomVMHostNameOne := gcp.RandomValidGcpName()
	randomVMHostNameTwo := gcp.RandomValidGcpName()
	randomVMHostNameThree := gcp.RandomValidGcpName()
	expectedIPNames := []string{
		randomVMHostNameOne, randomVMHostNameTwo, randomVMHostNameThree}

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfOptions := terraform.WithDefaultRetryableErrors(goTester, &terraform.Options{
		TerraformDir: moduleDir,
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region":   region,
			"ip_names": expectedIPNames,
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

	var externalIPPlan util.ExternalIPPlan
	err = json.Unmarshal([]byte(tfPlanJSON), &externalIPPlan)
	util.LogError(err, "Failed to parse the JSON plan into the ExternalIpPlan struct in unit/module_external_ip.go")

	/**
	 * Pro tip:
	 * Write the json to a file using the util.WriteToFile() method to easily debug
	 * util.WriteToFile(tfPlanJSON, "../../plan.json")
	 */

	// verify plan has ip_names input variable
	hasVar := assert.NotNil(
		goTester,
		externalIPPlan.Variables.IPNames,
		"Variable not found in plan: ip_names",
	)
	util.ExitIf(hasVar, false)

	// verify plan has region input variable
	hasVar = assert.NotNil(
		goTester,
		externalIPPlan.Variables.Region,
		"Variable not found in plan: region",
	)
	util.ExitIf(hasVar, false)

	// verify size of input variable ip_names array in plan
	assert.Len(
		goTester,
		externalIPPlan.Variables.IPNames.Value,
		len(expectedIPNames),
		"Variable count does not match in plan: ip_names.",
	)

	// verify input variable region in plan matches
	assert.Equal(
		goTester,
		region,
		externalIPPlan.Variables.Region.Value,
		"Variable does not match in plan: region.",
	)

	// verify each input variable ip_name in plan matches
	for _, ipName := range externalIPPlan.Variables.IPNames.Value {
		assert.Contains(
			goTester,
			expectedIPNames,
			ipName,
			"Variable does not match in plan: ip_names.",
		)
	}

	// verify output variable ips in plan matches
	hasVar = assert.NotNil(
		goTester,
		externalIPPlan.PlannedValues.Outputs.IPS,
		"Variable not found in plan: region",
	)
	util.ExitIf(hasVar, false)

	// verify the number of resources planned
	assert.Len(
		goTester,
		externalIPPlan.PlannedValues.RootModule.Resources,
		len(expectedIPNames),
		"Resource count does not match in plan: google_compute_address.",
	)

	// verify attributes of each planned resource
	for _, resource := range externalIPPlan.PlannedValues.RootModule.Resources {
		assert.Equal(
			goTester,
			"google_compute_address",
			resource.Type,
			"Resource type does not match.",
		)
		assert.Equal(
			goTester,
			"external_ip_address",
			resource.Name,
			"Resource name does not match.",
		)
		assert.Contains(
			goTester,
			expectedIPNames,
			resource.Values.Name,
			"Name given for an instance of the resource does not match.",
		)
		assert.Equal(
			goTester,
			"registry.terraform.io/hashicorp/google",
			resource.Provider,
			"Provider name does not match.",
		)
		assert.Equal(
			goTester,
			region,
			resource.Values.Region,
			"Region used for the external ip address does not match",
		)
		assert.Equal(
			goTester,
			"EXTERNAL",
			resource.Values.AddressType,
			"AddressType used for the external ip address is incorrect",
		)
	}
}
