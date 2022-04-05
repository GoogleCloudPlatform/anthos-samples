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
	"strconv"
	"testing"

	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/util"
	"github.com/GoogleCloudPlatform/anthos-samples/anthos-bm-gcp-terraform/validation"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/icrowley/fake"
)

func TestUnit_LoadbalancerModule_ControlPlane(goTester *testing.T) {
	goTester.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", "modules/loadbalancer")
	projectID := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT
	region := "test_region"
	zone := "test_zone"
	loadbalancerType := "controlplanelb"
	namePrefix := "cp-loadbalancer"
	externalIpName := "cp-lb-externalip"
	network := "default"
	healthCheckPath := "/health_check"
	healthCheckPort := util.GetRandomPort()
	backendProtocol := "TCP"

	randomVMHostNameOne := gcp.RandomValidGcpName()
	randomVMHostNameTwo := gcp.RandomValidGcpName()
	randomVMHostNameThree := gcp.RandomValidGcpName()

	randomVMIpNumOne := fake.IPv4()
	randomVMIpNumTwo := fake.IPv4()
	randomVMIpNumThree := fake.IPv4()

	randomVMPortNumOne := strconv.Itoa(util.GetRandomPort())
	randomVMPortNumTwo := strconv.Itoa(util.GetRandomPort())
	randomVMPortNumThree := strconv.Itoa(util.GetRandomPort())

	expectedVmHostNames := []string{
		randomVMHostNameOne, randomVMHostNameTwo, randomVMHostNameThree}
	expectedVmIps := []string{
		randomVMIpNumOne, randomVMIpNumTwo, randomVMIpNumThree}
	expectedVmPorts := []string{
		randomVMPortNumOne, randomVMPortNumTwo, randomVMPortNumThree}

	lbEndpointInstances := []interface{}{
		map[string]string{
			"name": randomVMHostNameOne,
			"ip":   randomVMIpNumOne,
			"port": randomVMPortNumOne,
		},
		map[string]string{
			"name": randomVMHostNameTwo,
			"ip":   randomVMIpNumTwo,
			"port": randomVMPortNumTwo,
		},
		map[string]string{
			"name": randomVMHostNameThree,
			"ip":   randomVMIpNumThree,
			"port": randomVMPortNumThree,
		},
	}

	forwardingRulePorts := []int{
		util.GetRandomPort(), util.GetRandomPort(), util.GetRandomPort(),
	}

	// Variables to pass to our Terraform code using -var options
	tfVarsMap := map[string]interface{}{
		"type":                  loadbalancerType,
		"project":               projectID,
		"region":                region,
		"zone":                  zone,
		"name_prefix":           namePrefix,
		"ip_name":               externalIpName,
		"network":               network,
		"lb_endpoint_instances": lbEndpointInstances,
		"health_check_path":     healthCheckPath,
		"health_check_port":     healthCheckPort,
		"backend_protocol":      backendProtocol,
		"forwarding_rule_ports": forwardingRulePorts,
	}

	testContainer := map[string]interface{}{
		"vmNames": expectedVmHostNames,
		"vmIps":   expectedVmIps,
		"vmPorts": expectedVmPorts,
	}

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfOptions := terraform.WithDefaultRetryableErrors(goTester, &terraform.Options{
		TerraformDir: moduleDir,
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

	var loadBalancerPlan util.LoadBalancerPlan
	err = json.Unmarshal([]byte(tfPlanJSON), &loadBalancerPlan)
	util.LogError(err, "Failed to parse the JSON plan into the LoadBalancerPlan struct in unit/module_loadbalancer.go")

	/**
	 * Pro tip:
	 * Write the json to a file using the util.WriteToFile() method to easily debug
	 * util.WriteToFile(tfPlanJSON, "../../plan.json")
	 */

	validation.ValidateLoadBalancerVariables(goTester, &loadBalancerPlan)
	validation.ValidateLoadBalancerVariableValues(goTester, &loadBalancerPlan, &tfVarsMap, &testContainer)

	moduleResources := map[string]string{
		"google_compute_backend_service":        "lb-backend",
		"google_compute_global_forwarding_rule": "lb-forwarding-rule",
		"google_compute_health_check":           "lb-health-check",
		"google_compute_network_endpoint":       "lb-network-endpoint",
		"google_compute_network_endpoint_group": "lb-neg",
		"google_compute_target_tcp_proxy":       "lb-target-tcp-proxy[0]",
	}
	validation.ValidateLoadBalancerPlanConfigurations(goTester, &loadBalancerPlan, &moduleResources, len(lbEndpointInstances))
}

func TestUnit_LoadbalancerModule_Ingress(goTester *testing.T) {
	goTester.Parallel()

	moduleDir := testStructure.CopyTerraformFolderToTemp(goTester, "../../", "modules/loadbalancer")
	projectID := gcp.GetGoogleProjectIDFromEnvVar(goTester) // from GOOGLE_CLOUD_PROJECT
	region := "test_region"
	zone := "test_zone"
	loadbalancerType := "ingresslb"
	namePrefix := "cp-loadbalancer"
	externalIpName := "cp-lb-externalip"
	network := "default"
	healthCheckPath := "/health_check"
	healthCheckPort := util.GetRandomPort()
	backendProtocol := "HTTP"

	randomVMHostNameOne := gcp.RandomValidGcpName()
	randomVMHostNameTwo := gcp.RandomValidGcpName()
	randomVMHostNameThree := gcp.RandomValidGcpName()

	randomVMIpNumOne := fake.IPv4()
	randomVMIpNumTwo := fake.IPv4()
	randomVMIpNumThree := fake.IPv4()

	randomVMPortNumOne := strconv.Itoa(util.GetRandomPort())
	randomVMPortNumTwo := strconv.Itoa(util.GetRandomPort())
	randomVMPortNumThree := strconv.Itoa(util.GetRandomPort())

	lbEndpointInstances := []interface{}{
		map[string]string{
			"name": randomVMHostNameOne,
			"ip":   randomVMIpNumOne,
			"port": randomVMPortNumOne,
		},
		map[string]string{
			"name": randomVMHostNameTwo,
			"ip":   randomVMIpNumTwo,
			"port": randomVMPortNumTwo,
		},
		map[string]string{
			"name": randomVMHostNameThree,
			"ip":   randomVMIpNumThree,
			"port": randomVMPortNumThree,
		},
	}

	forwardingRulePorts := []int{
		util.GetRandomPort(), util.GetRandomPort(), util.GetRandomPort(),
	}

	// Variables to pass to our Terraform code using -var options
	tfVarsMap := map[string]interface{}{
		"type":                  loadbalancerType,
		"project":               projectID,
		"region":                region,
		"zone":                  zone,
		"name_prefix":           namePrefix,
		"ip_name":               externalIpName,
		"network":               network,
		"lb_endpoint_instances": lbEndpointInstances,
		"health_check_path":     healthCheckPath,
		"health_check_port":     healthCheckPort,
		"backend_protocol":      backendProtocol,
		"forwarding_rule_ports": forwardingRulePorts,
	}

	tfPlanOutput := "terraform_test.tfplan"
	tfPlanOutputArg := fmt.Sprintf("-out=%s", tfPlanOutput)
	tfOptions := terraform.WithDefaultRetryableErrors(goTester, &terraform.Options{
		TerraformDir: moduleDir,
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

	var loadBalancerPlan util.LoadBalancerPlan
	err = json.Unmarshal([]byte(tfPlanJSON), &loadBalancerPlan)
	util.LogError(err, "Failed to parse the JSON plan into the LoadBalancerPlan struct in unit/module_loadbalancer.go")

	/**
	 * Pro tip:
	 * Write the json to a file using the util.WriteToFile() method to easily debug
	 * util.WriteToFile(tfPlanJSON, "../../plan.json")
	 */

	moduleResources := map[string]string{
		"google_compute_backend_service":        "lb-backend",
		"google_compute_global_forwarding_rule": "lb-forwarding-rule",
		"google_compute_health_check":           "lb-health-check",
		"google_compute_network_endpoint":       "lb-network-endpoint",
		"google_compute_network_endpoint_group": "lb-neg",
		"google_compute_target_http_proxy":      "lb-target-http-proxy[0]",
		"google_compute_url_map":                "ingress-lb-urlmap[0]",
	}
	validation.ValidateLoadBalancerPlanConfigurations(goTester, &loadBalancerPlan, &moduleResources, len(lbEndpointInstances))
}
