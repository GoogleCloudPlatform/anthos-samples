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
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/util"
	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/validation"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestUnit_VmModule(goTester *testing.T) {
	goTester.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", "modules/vm")
	projectID := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT
	region := gcp.GetRandomRegion(goTester, projectID, nil, nil)
	zone := gcp.GetRandomZoneForRegion(goTester, projectID, region)
	network := "default"
	instanceTemplate := fmt.Sprintf("/projects/%s/test_instance_template", projectID)
	randomVMHostNameOne := gcp.RandomValidGcpName()
	randomVMHostNameTwo := gcp.RandomValidGcpName()
	randomVMHostNameThree := gcp.RandomValidGcpName()
	expectedVMNames := []string{
		randomVMHostNameOne, randomVMHostNameTwo, randomVMHostNameThree}

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfOptions := terraform.WithDefaultRetryableErrors(goTester, &terraform.Options{
		TerraformDir: moduleDir,
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region":            region,
			"zone":              zone,
			"network":           network,
			"vm_names":          expectedVMNames,
			"instance_template": instanceTemplate,
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
	var vmInstancePlan util.VMInstancePlan
	err = json.Unmarshal([]byte(tfPlanJSON), &vmInstancePlan)
	util.LogError(err, "Failed to parse the JSON plan into the ExternalIpPlan struct in unit/module_vm.go")

	// verify plan has region input variable
	hasVar := assert.NotNil(
		goTester,
		vmInstancePlan.Variables.Region,
		"Variable not found in plan: region",
	)
	util.ExitIf(hasVar, false)

	// verify plan has zone input variable
	hasVar = assert.NotNil(
		goTester,
		vmInstancePlan.Variables.Zone,
		"Variable not found in plan: zone",
	)
	util.ExitIf(hasVar, false)

	// verify plan has network input variable
	hasVar = assert.NotNil(
		goTester,
		vmInstancePlan.Variables.Network,
		"Variable not found in plan: network",
	)
	util.ExitIf(hasVar, false)

	// verify plan has vm_names input variable
	hasVar = assert.NotNil(
		goTester,
		vmInstancePlan.Variables.Names,
		"Variable not found in plan: vm_names",
	)
	util.ExitIf(hasVar, false)

	// verify plan has instance_template input variable
	hasVar = assert.NotNil(
		goTester,
		vmInstancePlan.Variables.InstanceTemplate,
		"Variable not found in plan: instance_template",
	)
	util.ExitIf(hasVar, false)

	// verify input variable region in plan matches
	assert.Equal(
		goTester,
		region,
		vmInstancePlan.Variables.Region.Value,
		"Variable does not match in plan: region.",
	)

	// verify input variable zone in plan matches
	assert.Equal(
		goTester,
		zone,
		vmInstancePlan.Variables.Zone.Value,
		"Variable does not match in plan: zone.",
	)

	// verify input variable network in plan matches
	assert.Equal(
		goTester,
		network,
		vmInstancePlan.Variables.Network.Value,
		"Variable does not match in plan: network.",
	)

	// verify input variable instance_template in plan matches
	assert.Equal(
		goTester,
		instanceTemplate,
		vmInstancePlan.Variables.InstanceTemplate.Value,
		"Variable does not match in plan: instance_template.",
	)

	// verify size of input variable vm_names array in plan
	assert.Len(
		goTester,
		vmInstancePlan.Variables.Names.Value,
		len(expectedVMNames),
		"Variable count does not match in plan: vm_names.",
	)

	// verify each input variable vm_name in plan matches
	for _, vmName := range vmInstancePlan.Variables.Names.Value {
		assert.Contains(
			goTester,
			expectedVMNames,
			vmName,
			"Variable does not match in plan: vm_names.",
		)
	}

	// verify the number of resources planned
	assert.Len(
		goTester,
		vmInstancePlan.PlannedValues.RootModule.ChildModules,
		len(expectedVMNames)+1, // +1 for the external Ip resource
		"Resource count does not match in plan: google_compute_address.",
	)

	numberOfComputeInstanceModules := 0
	for idx, childModule := range vmInstancePlan.PlannedValues.RootModule.ChildModules {
		moduleAddress := childModule.ModuleAddress
		if strings.HasPrefix(moduleAddress, "module.compute_instance") {
			numberOfComputeInstanceModules++
			validation.ValidateComputeInstanceSubModule(
				goTester, &childModule, idx,
				&expectedVMNames, instanceTemplate, network, region)

		} else if strings.HasPrefix(moduleAddress, "module.external_ip_addresses") {
			assert.Len(
				goTester,
				childModule.Resources,
				len(expectedVMNames),
				fmt.Sprintf("Invalid count for planned_values.root_module.child_modules[%d].resources", idx),
			)

			for ipIdx, externalIPResource := range childModule.Resources {
				validation.ValidateExternalIPInSubModule(
					goTester, &externalIPResource, idx, ipIdx, &expectedVMNames, region)
			}
		} else {
			// child module should be either compute_instance or external_ip_addresses
			// it cannot be anything else
			goTester.Error(fmt.Sprintf(
				"Module 'vm' can only have the following sub modules: "+
					"\n\t- compute_instance"+
					"\n\t- external_ip_addresses"+
					"\n But it also has: %s",
				moduleAddress,
			))
			goTester.Fail()
		}
	}
	// verify how many child modules of type google_compute_instance_from_template were present
	assert.Len(
		goTester,
		expectedVMNames,
		numberOfComputeInstanceModules,
		"Resource count for module type google_compute_instance_from_template does not match in plan",
	)

	validation.ValidateOutputs(goTester, vmInstancePlan.PlannedValues.Outputs)
}

func TestUnit_VmModule_ValidateDefaults(goTester *testing.T) {
	goTester.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", "modules/vm")
	projectID := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT
	instanceTemplate := fmt.Sprintf("/projects/%s/test_instance_template", projectID)
	randomVMHostNameOne := gcp.RandomValidGcpName()
	randomVMHostNameTwo := gcp.RandomValidGcpName()
	randomVMHostNameThree := gcp.RandomValidGcpName()
	expectedVMNames := []string{
		randomVMHostNameOne, randomVMHostNameTwo, randomVMHostNameThree}

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfOptions := terraform.WithDefaultRetryableErrors(goTester, &terraform.Options{
		TerraformDir: moduleDir,
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"vm_names":          expectedVMNames,
			"instance_template": instanceTemplate,
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
	var vmInstancePlan util.VMInstancePlan
	err = json.Unmarshal([]byte(tfPlanJSON), &vmInstancePlan)
	util.LogError(err, "Failed to parse the JSON plan into the ExternalIpPlan struct in unit/module_vm.go")

	// verify input variable region in plan matches the default value
	assert.Equal(
		goTester,
		"us-central1",
		vmInstancePlan.Variables.Region.Value,
		"Variable does not match default value in plan: region.",
	)

	// verify input variable zone in plan matches the default value
	assert.Equal(
		goTester,
		"us-central1-a",
		vmInstancePlan.Variables.Zone.Value,
		"Variable does not match default value in plan: zone.",
	)

	// verify input variable network in plan matches the default value
	assert.Equal(
		goTester,
		"default",
		vmInstancePlan.Variables.Network.Value,
		"Variable does not match default value in plan: network.",
	)
}
