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

package util

// An ExternalIPPlan represents the root json object resulting from terraform
// plan on the external-ip module
type ExternalIPPlan struct {
	Variables     IPVariables     `json:"variables"`
	PlannedValues IPPlannedValues `json:"planned_values"`
}

// IPVariables represents the variables defined within the external-ip
// terraform module. When variables are added to the module this struct needs
// to be modified
type IPVariables struct {
	IPNames *IPNames  `json:"ip_names"`
	Region  *IPRegion `json:"region"`
}

// An IPRegion represents the 'region' variable which is part of the inputs
// for the external-ip terraform module
type IPRegion struct {
	Value string `json:"value"`
}

// IPNames represents the array of names to be given to newly created
// external-ips, which is configures as an input for the external-ip terraform
// module
type IPNames struct {
	Value []string `json:"value"`
}

// IPPlannedValues represent the planned state of the terraform run resulting
// from the input variables and the external-ip terraform module
type IPPlannedValues struct {
	Outputs    IPOutputs `json:"outputs"`
	RootModule TFModule  `json:"root_module"`
}

// IPOutputs represents the outputs produced by the external-ip terraform module
type IPOutputs struct {
	IPS *IPS `json:"ips"`
}

// IPS represent the external ip information that will be created as a result of
// running the external-ip terraform module
type IPS struct {
	Sensitive bool `json:"sensitive"`
}
