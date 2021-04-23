package test

import (
	"context"
	"fmt"
	"log"
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	compute "google.golang.org/api/compute/v1"
	"google.golang.org/api/googleapi"
)

func TestGcpInstance(t *testing.T) {
	t.Parallel()

	// moduleDir := test_structure.CopyTerraformFolderToTemp(t, "../", "modules/vm")
	projectId := gcp.GetGoogleProjectIDFromEnvVar(t) // from GOOGLE_CLOUD_PROJECT
	selfLinkPrefix := "https://www.googleapis.com/compute/v1/projects"

	// region := gcp.GetRandomRegion(t, projectId, nil, nil)
	// zone := gcp.GetRandomZoneForRegion(t, projectId, region)

	network := "default"
	sourceImageProject := "ubuntu-os-cloud"
	sourceImageFamily := "ubuntu-2004-focal-v20210415"

	// randomVmHostNameOne := gcp.RandomValidGcpName()
	// randomVmHostNameTwo := gcp.RandomValidGcpName()
	// randomVmHostNameThree := gcp.RandomValidGcpName()
	// vmNames := []string{
	// 	randomVmHostNameOne, randomVmHostNameTwo, randomVmHostNameThree}

	// create the go client SDK to create an instance template since terratest
	// doesn't have support for creating one
	// credentials for the context are looked up via GOOGLE_APPLICATION_CREDENTIALS
	ctx := context.Background()
	computeService, err := compute.NewService(ctx)
	LogError(err, "Failed to create new compute service for instance template creation")

	instanceTemplateService := compute.NewInstanceTemplatesService(computeService)
	testInstanceTemplate := gcp.RandomValidGcpName()
	networkSelfLink := fmt.Sprintf("%s/%s/global/networks/%s", selfLinkPrefix, projectId, network)
	sourceImageSelfLink := fmt.Sprintf("%s/%s/global/images/%s", selfLinkPrefix, sourceImageProject, sourceImageFamily)

	insertInsertTemplateCall := instanceTemplateService.Insert(projectId, &compute.InstanceTemplate{
		Name: testInstanceTemplate,
		Properties: &compute.InstanceProperties{
			CanIpForward:   true,
			MachineType:    "n1-standard-1",
			MinCpuPlatform: "Intel Haswell",
			Disks: []*compute.AttachedDisk{
				{
					Boot: true,
					InitializeParams: &compute.AttachedDiskInitializeParams{
						DiskSizeGb:  40,
						DiskType:    "pd-ssd",
						SourceImage: sourceImageSelfLink,
					},
				},
			},
			NetworkInterfaces: []*compute.NetworkInterface{
				{Network: networkSelfLink},
			},
			Tags: &compute.Tags{
				Items: []string{"http-server", "https-server"},
			},
		},
	})
	_, insertErr := insertInsertTemplateCall.Do()
	LogError(insertErr, fmt.Sprintf("Failed to create new instance template with name %s", testInstanceTemplate))
	instanceTemplatesDeleteCall := instanceTemplateService.Delete(projectId, testInstanceTemplate)
	defer deleteResource(instanceTemplatesDeleteCall, fmt.Sprintf("Failed to delete test instance template with name %s", testInstanceTemplate))

	// terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
	// 	TerraformDir: moduleDir,
	// 	// Variables to pass to our Terraform code using -var options
	// 	Vars: map[string]interface{}{
	// 		"region":            region,
	// 		"network":           network,
	// 		"vm_names":          vmNames,
	// 		"instance_template": template,
	// 	},
	// })
	// defer terraform.Destroy(t, terraformOptions)

}

type GcpOperation interface {
	Do(opts ...googleapi.CallOption) (*compute.Operation, error)
}

func deleteResource(fn GcpOperation, errMsg string) {
	_, err := fn.Do()
	LogError(err, errMsg)
}

func LogError(err error, errMsg string) {
	if err != nil {
		log.Print(fmt.Sprintf("%s:\n\t", errMsg))
		log.Fatal(err)
	}
}
