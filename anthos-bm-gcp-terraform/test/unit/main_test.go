package unit

import (
	"encoding/json"
	"fmt"
	"strconv"
	"testing"

	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/util"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestUnit_MainScript(goTester *testing.T) {
	goTester.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", ".")
	projectID := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT
	region := gcp.GetRandomRegion(goTester, projectID, nil, nil)
	zone := gcp.GetRandomZoneForRegion(goTester, projectID, region)
	credentialsFile := "/Users/shabirmean/.gcloud/shabir-abm-local-00830950f3ae.json"
	username := "test_username"
	minCpuPlatform := "test_cpu_platform"
	machineType := "test_machine_type"
	imageProject := "test_image_project"
	imageFamily := "test_image_family"
	bootDiskType := "test_boot_disk_type"
	abmClusterID := "test_abm_cluster_id"
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
		"test_primary_api_1",
		"test_primary_api_2",
	}
	secondaryApis := []string{
		"test_secondary_api_1",
		"test_secondary_api_2",
		"test_secondary_api_3",
	}
	instanceCount := map[string]int{
		"controlplane": 3,
		"worker":       2,
	}

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfVarsMap := map[string]interface{}{
		"project_id":                  projectID,
		"credentials_file":            credentialsFile,
		"region":                      region,
		"zone":                        zone,
		"username":                    username,
		"min_cpu_platform":            minCpuPlatform,
		"machine_type":                machineType,
		"image_project":               imageProject,
		"image_family":                imageFamily,
		"boot_disk_type":              bootDiskType,
		"boot_disk_size":              bootDiskSize,
		"network":                     network,
		"tags":                        tags,
		"access_scopes":               accessScopes,
		"anthos_service_account_name": anthosServiceAccountName,
		"primary_apis":                primaryApis,
		"secondary_apis":              secondaryApis,
		"abm_cluster_id":              abmClusterID,
		"instance_count":              instanceCount,
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
	util.LogError(err, "Failed to parse the JSON plan into the ExternalIpPlan struct in unit/module_external_ip.go")
	/**
	 * Pro tip:
	 * Write the json to a file using the util.WriteToFile() method to easily debug
	 * util.WriteToFile(tfPlanJSON, "../../plan.json")
	 */

	// validate the plan has the expected variables
	validateVariablesInMain(goTester, &terraformPlan)
	// validate the plan has the corect values set for the expected variables
	validateVariableValuesInMain(goTester, &terraformPlan, &tfVarsMap)

}

func validateVariablesInMain(goTester *testing.T, tfPlan *util.MainModulePlan) {
	// verify plan has project_id input variable
	hasVar := assert.NotNil(
		goTester,
		tfPlan.Variables.ProjectID,
		"Variable not found in plan: project_id",
	)
	util.ExitIf(hasVar, false)

	// verify plan has region input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Region,
		"Variable not found in plan: region",
	)
	util.ExitIf(hasVar, false)

	// verify plan has zone input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Zone,
		"Variable not found in plan: zone",
	)
	util.ExitIf(hasVar, false)

	// verify plan has network input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Network,
		"Variable not found in plan: network",
	)
	util.ExitIf(hasVar, false)

	// verify plan has username input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Username,
		"Variable not found in plan: username",
	)
	util.ExitIf(hasVar, false)

	// verify plan has abm_cluster_id input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.ABMClusterID,
		"Variable not found in plan: abm_cluster_id",
	)
	util.ExitIf(hasVar, false)

	// verify plan has anthos_service_account_name input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.AnthosServiceAccountName,
		"Variable not found in plan: anthos_service_account_name",
	)
	util.ExitIf(hasVar, false)

	// verify plan has boot_disk_size input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.BootDiskSize,
		"Variable not found in plan: boot_disk_size",
	)
	util.ExitIf(hasVar, false)

	// verify plan has boot_disk_type input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.BootDiskType,
		"Variable not found in plan: boot_disk_type",
	)
	util.ExitIf(hasVar, false)

	// verify plan has credentials_file input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.CrendetialsFile,
		"Variable not found in plan: credentials_file",
	)
	util.ExitIf(hasVar, false)

	// verify plan has image_family input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.ImageFamily,
		"Variable not found in plan: image_family",
	)
	util.ExitIf(hasVar, false)

	// verify plan has image_project input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.ImageProject,
		"Variable not found in plan: image_project",
	)
	util.ExitIf(hasVar, false)

	// verify plan has machine_type input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.MachineType,
		"Variable not found in plan: machine_type",
	)
	util.ExitIf(hasVar, false)

	// verify plan has min_cpu_platform input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.MinCPUPlatform,
		"Variable not found in plan: min_cpu_platform",
	)
	util.ExitIf(hasVar, false)

	// verify plan has tags input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Tags,
		"Variable not found in plan: tags",
	)
	util.ExitIf(hasVar, false)

	// verify plan has tags input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Tags,
		"Variable not found in plan: tags",
	)
	util.ExitIf(hasVar, false)

	// verify plan has access_scopes input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.AccessScope,
		"Variable not found in plan: access_scopes",
	)
	util.ExitIf(hasVar, false)

	// verify plan has primary_apis input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.PrimaryAPIs,
		"Variable not found in plan: primary_apis",
	)
	util.ExitIf(hasVar, false)

	// verify plan has secondary_apis input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.SecondaryAPIs,
		"Variable not found in plan: secondary_apis",
	)
	util.ExitIf(hasVar, false)

	// verify plan has instance_count input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.InstanceCount,
		"Variable not found in plan: instance_count",
	)
	util.ExitIf(hasVar, false)
}

func validateVariableValuesInMain(goTester *testing.T, tfPlan *util.MainModulePlan, vars *map[string]interface{}) {
	// verify input variable project_id in plan matches
	assert.Equal(
		goTester,
		(*vars)["project_id"],
		tfPlan.Variables.ProjectID.Value,
		"Variable does not match in plan: project_id.",
	)

	// verify input variable credentials_file in plan matches
	assert.Equal(
		goTester,
		(*vars)["region"],
		tfPlan.Variables.Region.Value,
		"Variable does not match in plan: credentials_file.",
	)

	// verify input variable zone in plan matches
	assert.Equal(
		goTester,
		(*vars)["zone"],
		tfPlan.Variables.Zone.Value,
		"Variable does not match in plan: zone.",
	)

	// verify input variable network in plan matches
	assert.Equal(
		goTester,
		(*vars)["network"],
		tfPlan.Variables.Network.Value,
		"Variable does not match in plan: network.",
	)

	// verify input variable username in plan matches
	assert.Equal(
		goTester,
		(*vars)["username"],
		tfPlan.Variables.Username.Value,
		"Variable does not match in plan: username.",
	)

	// verify input variable abm_cluster_id in plan matches
	assert.Equal(
		goTester,
		(*vars)["abm_cluster_id"],
		tfPlan.Variables.ABMClusterID.Value,
		"Variable does not match in plan: abm_cluster_id.",
	)

	// verify input variable anthos_service_account_name in plan matches
	assert.Equal(
		goTester,
		(*vars)["anthos_service_account_name"],
		tfPlan.Variables.AnthosServiceAccountName.Value,
		"Variable does not match in plan: anthos_service_account_name.",
	)

	// verify input variable boot_disk_size in plan matches
	planValue, _ := strconv.Atoi(tfPlan.Variables.BootDiskSize.Value)
	assert.Equal(
		goTester,
		(*vars)["boot_disk_size"],
		planValue,
		"Variable does not match in plan: boot_disk_size.",
	)

	// verify input variable boot_disk_type in plan matches
	assert.Equal(
		goTester,
		(*vars)["boot_disk_type"],
		tfPlan.Variables.BootDiskType.Value,
		"Variable does not match in plan: boot_disk_type.",
	)

	// verify input variable credentials_file in plan matches
	assert.Equal(
		goTester,
		(*vars)["credentials_file"],
		tfPlan.Variables.CrendetialsFile.Value,
		"Variable does not match in plan: credentials_file.",
	)

	// verify input variable image_family in plan matches
	assert.Equal(
		goTester,
		(*vars)["image_family"],
		tfPlan.Variables.ImageFamily.Value,
		"Variable does not match in plan: image_family.",
	)

	// verify input variable image_project in plan matches
	assert.Equal(
		goTester,
		(*vars)["image_project"],
		tfPlan.Variables.ImageProject.Value,
		"Variable does not match in plan: image_project.",
	)

	// verify input variable machine_type in plan matches
	assert.Equal(
		goTester,
		(*vars)["machine_type"],
		tfPlan.Variables.MachineType.Value,
		"Variable does not match in plan: machine_type.",
	)

	// verify input variable min_cpu_platform in plan matches
	assert.Equal(
		goTester,
		(*vars)["min_cpu_platform"],
		tfPlan.Variables.MinCPUPlatform.Value,
		"Variable does not match in plan: min_cpu_platform.",
	)

	// verify input variable tags in plan matches every tag in the list
	for _, tag := range tfPlan.Variables.Tags.Value {
		assert.Contains(
			goTester,
			(*vars)["tags"],
			tag,
			"Variable does not match in plan: tags.",
		)
	}

	// verify input variable access_scopes in plan matches every access_scope in the list
	for _, accessScope := range tfPlan.Variables.AccessScope.Value {
		assert.Contains(
			goTester,
			(*vars)["access_scopes"],
			accessScope,
			"Variable does not match in plan: access_scopes.",
		)
	}

	// verify input variable primary_apis in plan matches every api in the list
	for _, api := range tfPlan.Variables.PrimaryAPIs.Value {
		assert.Contains(
			goTester,
			(*vars)["primary_apis"],
			api,
			"Variable does not match in plan: primary_apis.",
		)
	}

	// verify input variable secondary_apis in plan matches every api in the list
	for _, api := range tfPlan.Variables.SecondaryAPIs.Value {
		assert.Contains(
			goTester,
			(*vars)["secondary_apis"],
			api,
			"Variable does not match in plan: secondary_apis.",
		)
	}

	// verify input variable instance_count in plan matches required types of instances
	instanceCountMapInTest := (*vars)["instance_count"].(map[string]int)
	instanceCountInPlan := tfPlan.Variables.InstanceCount.Value
	validNames := []string{}
	for k := range instanceCountMapInTest {
		validNames = append(validNames, k)
	}
	for name, vmCount := range instanceCountInPlan {
		assert.Contains(
			goTester,
			validNames,
			name,
			"Variable does not match in plan: instance_count.",
		)

		assert.Equal(
			goTester,
			instanceCountMapInTest[name],
			vmCount,
			fmt.Sprintf("Variable does not match in plan: instance_count for %s.", name),
		)
	}
}
