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
	init_script := "test_instance_template"
	preflight_script := "test_instance_template"
	init_logs := "test_instance_template"
	init_vars_file := "test_instance_template"
	// cluster_yaml_path := "test_instance_template"
	// pub_key_path_template := "test_instance_template"
	// priv_key_path_template := "test_instance_template"

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
			// "cluster_yaml_path":      cluster_yaml_path,
			// "pub_key_path_template":  pub_key_path_template,
			// "priv_key_path_template": priv_key_path_template,
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
	util.WriteToFile(tfPlanJSON, "../../plan.json")
}
