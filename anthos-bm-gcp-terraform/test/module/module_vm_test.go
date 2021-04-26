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

package module

import (
	"context"
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/util"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	compute "google.golang.org/api/compute/v1"
)

func TestModule_VmModule(t *testing.T) {
	t.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(t, "../../", "modules/vm")
	projectId := gcp.GetGoogleProjectIDFromEnvVar(t) // from GOOGLE_CLOUD_PROJECT
	selfLinkPrefix := "https://www.googleapis.com/compute/v1/projects"
	region := gcp.GetRandomRegion(t, projectId, nil, nil)
	// zone := gcp.GetRandomZoneForRegion(t, projectId, region)

	network := "default"
	sourceImageProject := "ubuntu-os-cloud"
	sourceImageFamily := "ubuntu-2004-focal-v20210415"

	randomVmHostNameOne := gcp.RandomValidGcpName()
	randomVmHostNameTwo := gcp.RandomValidGcpName()
	randomVmHostNameThree := gcp.RandomValidGcpName()
	vmNames := []string{
		randomVmHostNameOne, randomVmHostNameTwo, randomVmHostNameThree}

	// create the go client SDK to create an instance template since terratest
	// doesn't have support for creating one
	// credentials for the context are looked up via GOOGLE_APPLICATION_CREDENTIALS
	ctx := context.Background()
	computeService, err := compute.NewService(ctx)
	util.LogError(err, "Failed to create new compute service for instance template creation")

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
	util.LogError(insertErr, fmt.Sprintf("Failed to create new instance template with name %s", testInstanceTemplate))
	instanceTemplatesDeleteCall := instanceTemplateService.Delete(projectId, testInstanceTemplate)
	defer util.DeleteResource(instanceTemplatesDeleteCall, fmt.Sprintf("Failed to delete test instance template with name %s", testInstanceTemplate))

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: moduleDir,
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region":            region,
			"network":           network,
			"vm_names":          vmNames,
			"instance_template": testInstanceTemplate,
		},
	})
	defer terraform.Destroy(t, terraformOptions)

	// run `terraform init` and `terraform apply`
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of 'ips' output
	vmInfoList := terraform.OutputList(t, terraformOptions, "vm_info")
	for _, vm := range vmInfoList {
		fmt.Printf(vm)
	}
}
