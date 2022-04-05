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

package util

// An LoadBalancerPlan represents the root json object resulting from terraform
// plan on the loadbalancer module
type LoadBalancerPlan struct {
	Variables     LBVariables     `json:"variables"`
	PlannedValues LBPlannedValues `json:"planned_values"`
}

// LBVariables represents the variables defined within the loadbalancer
// terraform module. When variables are added to the module this struct needs
// to be modified
type LBVariables struct {
	Type             *Variable                      `json:"type"`
	ProjectId        *Variable                      `json:"project"`
	Region           *Variable                      `json:"region"`
	Zone             *Variable                      `json:"zone"`
	NamePrefix       *Variable                      `json:"name_prefix"`
	ExternalIPName   *Variable                      `json:"ip_name"`
	Network          *Variable                      `json:"network"`
	HealthCheckPath  *Variable                      `json:"health_check_path"`
	HealthCheckPort  *Variable                      `json:"health_check_port"`
	Protocol         *Variable                      `json:"backend_protocol"`
	ForwardRulePort  *ListIntVariable               `json:"forwarding_rule_ports"`
	NetworkEndpoints *LBNetworkEndpointListVariable `json:"lb_endpoint_instances"`
}

// LBNetworkEndpoint is an object representing one virtual machine that serves
// as a backend endpoint for the loadbalancer
type LBNetworkEndpoint struct {
	Name string `json:"name"`
	IP   string `json:"ip"`
	Port string `json:"port"`
}

// LBNetworkEndpointListVariable represents an instance of a single terraform
// input variable which holds a list of netowrk endpoint objects:
// 		list(object({ name = string, port = number, ip = string }))
type LBNetworkEndpointListVariable struct {
	Value []LBNetworkEndpoint `json:"value"`
}

// LBPlannedValues represent the planned state of the terraform run resulting
// from the input variables upon the loadbalancer terraform module
type LBPlannedValues struct {
	Outputs    LBOutputs `json:"outputs"`
	RootModule TFModule  `json:"root_module"`
}

// LBOutputs represents the outputs produced by the loadbalancer terraform
// module
type LBOutputs struct {
	PublicIP                 *SensitiveVariable `json:"public_ip"`
	NetworkEndpointGroupName *Variable          `json:"neg_name"`
}
