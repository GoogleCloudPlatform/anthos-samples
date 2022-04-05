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
	"strconv"
	"testing"

	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/util"
	"github.com/stretchr/testify/assert"
)

// ValidateLoadBalancerVariables validates for correctness of the variables set
// for the `loadbalancer` module.
func ValidateLoadBalancerVariables(goTester *testing.T, tfPlan *util.LoadBalancerPlan) {
	// verify plan has project input variable
	hasVar := assert.NotNil(
		goTester,
		tfPlan.Variables.ProjectID,
		"Variable not found in plan: project",
	)
	util.ExitIf(hasVar, false)

	// verify plan has type input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Type,
		"Variable not found in plan: type",
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

	// verify plan has name_prefix input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.NamePrefix,
		"Variable not found in plan: name_prefix",
	)
	util.ExitIf(hasVar, false)

	// verify plan has ip_name input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.ExternalIPName,
		"Variable not found in plan: ip_name",
	)
	util.ExitIf(hasVar, false)

	// verify plan has network input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.Network,
		"Variable not found in plan: network",
	)
	util.ExitIf(hasVar, false)

	// verify plan has lb_endpoint_instances input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.NetworkEndpoints,
		"Variable not found in plan: lb_endpoint_instances",
	)
	util.ExitIf(hasVar, false)

	// verify plan has health_check_path input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.HealthCheckPath,
		"Variable not found in plan: health_check_path",
	)
	util.ExitIf(hasVar, false)

	// verify plan has health_check_port input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.HealthCheckPort,
		"Variable not found in plan: health_check_port",
	)
	util.ExitIf(hasVar, false)

	// verify plan has forwarding_rule_ports input variable
	hasVar = assert.NotNil(
		goTester,
		tfPlan.Variables.ForwardRulePort,
		"Variable not found in plan: forwarding_rule_ports",
	)
	util.ExitIf(hasVar, false)
}

// ValidateLoadBalancerVariableValues validates whether the values of the
// variables set for the `loadbalancer` module matches the ones defined in the
// test function.
func ValidateLoadBalancerVariableValues(
	goTester *testing.T, tfPlan *util.LoadBalancerPlan,
	vars *map[string]interface{}, testContainer *map[string]interface{}) {
	// verify input variable project in plan matches
	assert.Equal(
		goTester,
		(*vars)["project"],
		tfPlan.Variables.ProjectID.Value,
		"Variable does not match in plan: project.",
	)

	// verify input variable type in plan matches
	assert.Equal(
		goTester,
		(*vars)["type"],
		tfPlan.Variables.Type.Value,
		"Variable does not match in plan: type.",
	)

	// verify input variable region in plan matches
	assert.Equal(
		goTester,
		(*vars)["region"],
		tfPlan.Variables.Region.Value,
		"Variable does not match in plan: region.",
	)

	// verify input variable zone in plan matches
	assert.Equal(
		goTester,
		(*vars)["zone"],
		tfPlan.Variables.Zone.Value,
		"Variable does not match in plan: zone.",
	)

	// verify input variable name_prefix in plan matches
	assert.Equal(
		goTester,
		(*vars)["name_prefix"],
		tfPlan.Variables.NamePrefix.Value,
		"Variable does not match in plan: name_prefix.",
	)

	// verify input variable ip_name in plan matches
	assert.Equal(
		goTester,
		(*vars)["ip_name"],
		tfPlan.Variables.ExternalIPName.Value,
		"Variable does not match in plan: ip_name.",
	)

	// verify input variable network in plan matches
	assert.Equal(
		goTester,
		(*vars)["network"],
		tfPlan.Variables.Network.Value,
		"Variable does not match in plan: network.",
	)

	// verify input variable health_check_path in plan matches
	assert.Equal(
		goTester,
		(*vars)["health_check_path"],
		tfPlan.Variables.HealthCheckPath.Value,
		"Variable does not match in plan: health_check_path.",
	)

	portNum, _ := strconv.Atoi(tfPlan.Variables.HealthCheckPort.Value)
	// verify input variable health_check_port in plan matches
	assert.Equal(
		goTester,
		(*vars)["health_check_port"],
		portNum,
		"Variable does not match in plan: health_check_port.",
	)

	// verify input variable backend_protocol in plan matches
	assert.Equal(
		goTester,
		(*vars)["backend_protocol"],
		tfPlan.Variables.Protocol.Value,
		"Variable does not match in plan: backend_protocol.",
	)

	// verify input variable forwarding_rule_ports in plan matches
	for _, port := range tfPlan.Variables.ForwardRulePort.Value {
		assert.Contains(
			goTester,
			(*vars)["forwarding_rule_ports"],
			port,
			"Variable does not match in plan: forwarding_rule_ports",
		)
	}

	// verify input variable lb_endpoint_instances in plan matches the
	// (name, ip. port) combination of each object used
	for _, netEndpoint := range tfPlan.Variables.NetworkEndpoints.Value {
		assert.Contains(
			goTester,
			(*testContainer)["vmNames"],
			netEndpoint.Name,
			"Variable does not match in plan: lb_endpoint_instances.name",
		)
		assert.Contains(
			goTester,
			(*testContainer)["vmIps"],
			netEndpoint.IP,
			"Variable does not match in plan: lb_endpoint_instances.ip",
		)
		assert.Contains(
			goTester,
			(*testContainer)["vmPorts"],
			netEndpoint.Port,
			"Variable does not match in plan: lb_endpoint_instances.port",
		)
	}
}

// ValidateLoadBalancerPlanConfigurations validates for correctness of the
// terraform actions in the terraform plan for the `loadbalancer` module.
func ValidateLoadBalancerPlanConfigurations(
	goTester *testing.T, tfPlan *util.LoadBalancerPlan,
	moduleResources *map[string]string, networkEndpointCount int) {

	networkEndpointResourcesInPlan := 0

	for _, configResource := range tfPlan.PlannedValues.RootModule.Resources {
		resourceType := configResource.Type
		resourceName := configResource.Name
		resourceValue, isValidResouce := (*moduleResources)[resourceType]
		assert.True(
			goTester,
			isValidResouce,
			fmt.Sprintf("loadbalancer module has an unexpected module: %s", resourceType),
		)
		assert.Contains(
			goTester,
			resourceValue,
			resourceName,
			fmt.Sprintf("Resource name in loadbalancer module doesn't contain expected substring: %s - %s", resourceValue, resourceName),
		)
		if resourceType == "google_compute_network_endpoint" {
			networkEndpointResourcesInPlan++
		}
	}

	assert.Equal(
		goTester,
		networkEndpointResourcesInPlan,
		networkEndpointCount,
		"Invalid number of 'google_compute_network_endpoint' resources in the loadbalancer module",
	)

	childModules := tfPlan.PlannedValues.RootModule.ChildModules
	assert.Equal(
		goTester,
		len(childModules),
		1,
		"Invalid number of child modules in loadbalancer module. Should be only the external_ip module",
	)
	assert.Equal(
		goTester,
		childModules[0].Resources[0].Type,
		"google_compute_global_address",
		"Invalid resource type for child module of module - loadbalancer",
	)
}
