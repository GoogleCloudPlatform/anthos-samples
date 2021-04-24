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
	projectId := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT
	region := gcp.GetRandomRegion(goTester, projectId, nil, nil)
	randomVmHostNameOne := gcp.RandomValidGcpName()
	randomVmHostNameTwo := gcp.RandomValidGcpName()
	randomVmHostNameThree := gcp.RandomValidGcpName()
	expectedIpNames := []string{
		randomVmHostNameOne, randomVmHostNameTwo, randomVmHostNameThree}

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfOptions := terraform.WithDefaultRetryableErrors(goTester, &terraform.Options{
		TerraformDir: moduleDir,
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region":   region,
			"ip_names": expectedIpNames,
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

	var externalIpPlan ExternalIpPlan
	err = json.Unmarshal([]byte(tfPlanJSON), &externalIpPlan)
	util.LogError(err, "Failed to parse the JSON plan into the ExternalIpPlan struct in unit/module_external_ip.go")

	// verify plan has ip_names input variable
	hasVar := assert.NotNil(
		goTester,
		externalIpPlan.Variables.IPNames,
		"Variable not found in plan: ip_names",
	)
	util.ExitIf(hasVar, true)

	// verify plan has region input variable
	hasVar = assert.NotNil(
		goTester,
		externalIpPlan.Variables.Region,
		"Variable not found in plan: region",
	)
	util.ExitIf(hasVar, true)

	// verify size of input variable ip_names array in plan
	assert.Len(
		goTester,
		externalIpPlan.Variables.IPNames.Value,
		len(expectedIpNames),
		"Variable count does not match in plan: ip_names.",
	)

	// verify input variable region in plan matches
	assert.Equal(
		goTester,
		region,
		externalIpPlan.Variables.Region.Value,
		"Variable does not match in plan: region.",
	)

	// verify each input variable ip_name in plan matches
	for _, ipName := range externalIpPlan.Variables.IPNames.Value {
		assert.Contains(
			goTester,
			expectedIpNames,
			ipName,
			"Variable does not match in plan: ip_names.",
		)
	}

	// verify output variable ips in plan matches
	hasVar = assert.NotNil(
		goTester,
		externalIpPlan.PlannedValues.Outputs.IPS,
		"Variable not found in plan: region",
	)
	util.ExitIf(hasVar, true)

	assert.Len(
		goTester,
		externalIpPlan.PlannedValues.RootModule.Resources,
		len(expectedIpNames),
		"Resource count does not match in plan: google_compute_address.",
	)

	for _, resource := range externalIpPlan.PlannedValues.RootModule.Resources {
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
			expectedIpNames,
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
