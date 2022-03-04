// Copyright 2022 Google LLC
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

package validation

import (
	"fmt"
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/util"
	"github.com/stretchr/testify/assert"
)

// ValidateComputeInstanceSubModule validates correctness of the
// `terraform-google-modules/vm/google//modules/compute_instance`
// module referenced from the vm module.
func ValidateComputeInstanceSubModule(
	goTester *testing.T, childModule *util.TFModule,
	idx int, expectedVMNames *[]string,
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
		*expectedVMNames,
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

// ValidateExternalIPInSubModule validates correctness of the `external-ip`
// module referenced from the vm module.
func ValidateExternalIPInSubModule(
	goTester *testing.T, externalIPResource *util.TFResource,
	idx int, ipIdx int, expectedIPNames *[]string, region string) {

	assert.Equal(
		goTester,
		"google_compute_address",
		externalIPResource.Type,
		fmt.Sprintf("Invalid type for planned_values.root_module.child_modules[%d].resources[%d].type", idx, ipIdx),
	)
	assert.Equal(
		goTester,
		"external_ip_address",
		externalIPResource.Name,
		fmt.Sprintf("Invalid resource name for planned_values.root_module.child_modules[%d].resources[%d].name", idx, ipIdx),
	)
	assert.Equal(
		goTester,
		"registry.terraform.io/hashicorp/google",
		externalIPResource.Provider,
		fmt.Sprintf("Invalid provider for planned_values.root_module.child_modules[%d].resources[%d].provider", idx, ipIdx),
	)
	assert.Contains(
		goTester,
		*expectedIPNames,
		externalIPResource.Values.Name,
		fmt.Sprintf("Invalid resource instance name for planned_values.root_module.child_modules[%d].resources[%d].values.name", idx, ipIdx),
	)
	assert.Equal(
		goTester,
		region,
		externalIPResource.Values.Region,
		fmt.Sprintf("Invalid resource region planned_values.root_module.child_modules[%d].resources[%d].values.region", idx, ipIdx),
	)
}

// ValidateOutputs validates if the outputs in the terraform plan matches
// the outputs defined in the `output.tf` of the vm module.
func ValidateOutputs(goTester *testing.T, vmPlanOutputs *util.VMOutputs) {
	// verify module produces output in plan
	assert.NotNil(
		goTester,
		vmPlanOutputs,
		"Module is expected to produce outputs; but none found",
	)

	// verify module produces an output for vm_info in plan
	assert.NotNil(
		goTester,
		vmPlanOutputs.VMInfo,
		"Module is expected to have an output for vm_info; but not found",
	)
}
