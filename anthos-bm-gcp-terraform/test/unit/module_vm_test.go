package unit

import (
	"encoding/json"
	"fmt"
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/util"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestUnit_VmModule(goTester *testing.T) {
	goTester.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", "modules/vm")
	projectId := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT
	region := gcp.GetRandomRegion(goTester, projectId, nil, nil)
	network := "default"
	instanceTemplate := "test_instance_template"
	randomVmHostNameOne := gcp.RandomValidGcpName()
	randomVmHostNameTwo := gcp.RandomValidGcpName()
	randomVmHostNameThree := gcp.RandomValidGcpName()
	expectedVmNames := []string{
		randomVmHostNameOne, randomVmHostNameTwo, randomVmHostNameThree}

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfOptions := terraform.WithDefaultRetryableErrors(goTester, &terraform.Options{
		TerraformDir: moduleDir,
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region":            region,
			"network":           network,
			"vm_names":          expectedVmNames,
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
	var vmInstancePlan VMInstancePlan
	err = json.Unmarshal([]byte(tfPlanJSON), &vmInstancePlan)
	util.LogError(err, "Failed to parse the JSON plan into the ExternalIpPlan struct in unit/module_external_ip.go")

	// verify plan has region input variable
	hasVar := assert.NotNil(
		goTester,
		vmInstancePlan.Variables.Region,
		"Variable not found in plan: region",
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
		len(expectedVmNames),
		"Variable count does not match in plan: vm_names.",
	)

	// verify each input variable vm_name in plan matches
	for _, vmName := range vmInstancePlan.Variables.Names.Value {
		assert.Contains(
			goTester,
			expectedVmNames,
			vmName,
			"Variable does not match in plan: vm_names.",
		)
	}

	// verify the number of resources planned
	assert.Len(
		goTester,
		vmInstancePlan.PlannedValues.RootModule.VMChildModules,
		len(expectedVmNames)+1, // +1 for the external Ip resource
		"Resource count does not match in plan: google_compute_address.",
	)

	numberOfComputeInstanceModules := 0
	for idx, childModule := range vmInstancePlan.PlannedValues.RootModule.VMChildModules {
		moduleAddress := childModule.ModuleAddress
		if strings.HasPrefix(moduleAddress, "module.compute_instance") {
			numberOfComputeInstanceModules++
			validateComputeInstanceSubModule(
				goTester, &childModule, idx,
				&expectedVmNames, instanceTemplate, network, region)

		} else if strings.HasPrefix(moduleAddress, "module.external_ip_addresses") {
			assert.Len(
				goTester,
				childModule.Resources,
				len(expectedVmNames),
				fmt.Sprintf("Invalid count for planned_values.root_module.child_modules[%d].resources", idx),
			)

			for ipIdx, externalIpResource := range childModule.Resources {
				validateExternalIpInSubModule(
					goTester, &externalIpResource, idx, ipIdx, &expectedVmNames, region)
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
		expectedVmNames,
		numberOfComputeInstanceModules,
		"Resource count for module type google_compute_instance_from_template does not match in plan",
	)
}

func validateComputeInstanceSubModule(
	goTester *testing.T, childModule *VMChildModule,
	idx int, expectedVmNames *[]string,
	instanceTemplate string, network string, region string) {
	lenMatch := assert.Len(
		goTester,
		childModule.Resources,
		1, // each compute instance child module has just 1 resource definition,
		fmt.Sprintf("Invalid count for planned_values.root_module.child_modules[%d].resources", idx),
	)
	util.ExitIf(lenMatch, false)

	childResource := childModule.Resources[0]
	assert.Equal(
		goTester,
		"google_compute_instance_from_template",
		childResource.Type,
		fmt.Sprintf("Invalid type for planned_values.root_module.child_modules[%d].resources[0].type", idx),
	)
	assert.Equal(
		goTester,
		"compute_instance",
		childResource.Name,
		fmt.Sprintf("Invalid resource name for planned_values.root_module.child_modules[%d].resources[0].name", idx),
	)
	assert.Equal(
		goTester,
		"registry.terraform.io/hashicorp/google",
		childResource.Provider,
		fmt.Sprintf("Invalid provider for planned_values.root_module.child_modules[%d].resources[0].provider", idx),
	)
	assert.Contains(
		goTester,
		*expectedVmNames,
		// vm names have -001 appended to them by module google_compute_instance_from_template
		strings.Replace(childResource.Values.Name, "-001", "", 1),
		fmt.Sprintf("Invalid resource instance name for planned_values.root_module.child_modules[%d].resources[0].values.name", idx),
	)
	assert.True(
		goTester,
		strings.HasPrefix(childResource.Values.Zone, region),
		fmt.Sprintf("Invalid resource instance name for planned_values.root_module.child_modules[%d].resources[0].values.name", idx),
	)
	assert.Equal(
		goTester,
		network,
		childResource.Values.NetworkInterfaces[0].Network,
		fmt.Sprintf("Invalid network for planned_values.root_module.child_modules[%d].resources[0].values.source_instance_template", idx),
	)
	assert.Equal(
		goTester,
		instanceTemplate,
		childResource.Values.InstanceTemplate,
		fmt.Sprintf("Invalid instance template for planned_values.root_module.child_modules[%d].resources[0].values.source_instance_template", idx),
	)
}

func validateExternalIpInSubModule(
	goTester *testing.T, externalIpResource *VMResource,
	idx int, ipIdx int, expectedIpNames *[]string, region string) {

	assert.Equal(
		goTester,
		"google_compute_address",
		externalIpResource.Type,
		fmt.Sprintf("Invalid type for planned_values.root_module.child_modules[%d].resources[%d].type", idx, ipIdx),
	)
	assert.Equal(
		goTester,
		"external_ip_address",
		externalIpResource.Name,
		fmt.Sprintf("Invalid resource name for planned_values.root_module.child_modules[%d].resources[%d].name", idx, ipIdx),
	)
	assert.Equal(
		goTester,
		"registry.terraform.io/hashicorp/google",
		externalIpResource.Provider,
		fmt.Sprintf("Invalid provider for planned_values.root_module.child_modules[%d].resources[%d].provider", idx, ipIdx),
	)
	assert.Contains(
		goTester,
		*expectedIpNames,
		externalIpResource.Values.Name,
		fmt.Sprintf("Invalid resource instance name for planned_values.root_module.child_modules[%d].resources[%d].values.name", idx, ipIdx),
	)
	assert.Equal(
		goTester,
		region,
		externalIpResource.Values.Region,
		fmt.Sprintf("Invalid resource region planned_values.root_module.child_modules[%d].resources[%d].values.region", idx, ipIdx),
	)
}
