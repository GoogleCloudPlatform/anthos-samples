package test

import (
	"fmt"
	"net"
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestExternalIps(t *testing.T) {
	t.Parallel()

	moduleDir := test_structure.CopyTerraformFolderToTemp(t, "../", "modules/external-ip")
	projectId := gcp.GetGoogleProjectIDFromEnvVar(t) // from GOOGLE_CLOUD_PROJECT
	region := gcp.GetRandomRegion(t, projectId, nil, nil)

	randomVmHostNameOne := gcp.RandomValidGcpName()
	randomVmHostNameTwo := gcp.RandomValidGcpName()
	randomVmHostNameThree := gcp.RandomValidGcpName()
	expectedIpNames := []string{
		randomVmHostNameOne, randomVmHostNameTwo, randomVmHostNameThree}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: moduleDir,
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region":   region,
			"ip_names": expectedIpNames,
		},
	})
	defer terraform.Destroy(t, terraformOptions)

	// run `terraform init` and `terraform apply`
	terraform.InitAndApply(t, terraformOptions)
	// Run `terraform output` to get the value of 'ips' output
	ipAddressDetails := terraform.OutputMapOfObjects(t, terraformOptions, "ips")

	// validate that the output contians an entry per name in expectedIpNames
	errMsg := fmt.Sprintf("Output from external-ip module should have %d IP names but only got %d", len(expectedIpNames), len(ipAddressDetails))
	assert.True(t, len(expectedIpNames) == len(ipAddressDetails), errMsg)

	for _, ip := range expectedIpNames {
		errMsg := fmt.Sprintf("Output from external-ip module should have IP name: %s", ip)
		assert.Contains(t, ipAddressDetails, ip, errMsg)
	}
	// validate that each ip object consistes of a `tier`, `address` and `region` attributes
	for _, detail := range ipAddressDetails {
		detailsMap := detail.(map[string]interface{})
		errMsg := fmt.Sprintf("external-ip module output object's region does not match selected region: %s", region)
		assert.Contains(t, detailsMap, "tier", "external-ip module output object does not have attribute: tier")
		assert.Contains(t, detailsMap, "address", "external-ip module output object does not have attribute: address")
		assert.Contains(t, detailsMap, "region", "external-ip module output object does not have attribute: region")

		ipAddress := fmt.Sprintf("%v", detailsMap["address"])
		assert.Equal(t, detailsMap["region"], region, errMsg)
		assert.True(t, net.ParseIP(ipAddress) != nil)
	}
}
