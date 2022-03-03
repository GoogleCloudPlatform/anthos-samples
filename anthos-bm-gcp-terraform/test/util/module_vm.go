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

// An VMInstancePlan represents the root json object resulting from terraform
// plan on the vm module
type VMInstancePlan struct {
	Variables     VMVariables     `json:"variables"`
	PlannedValues VMPlannedValues `json:"planned_values"`
}

// VMVariables represents the variables defined within the external-ip
// terraform module. When variables are added to the module this struct needs
// to be modified
type VMVariables struct {
	Region           *Variable       `json:"region"`
	Zone             *Variable       `json:"zone"`
	Network          *Variable       `json:"network"`
	Names            *VMVarValueList `json:"vm_names"`
	InstanceTemplate *Variable       `json:"instance_template"`
}

// VMVarValueList represents an instance of a single terraform input variable
// which is a list item in the vm terraform module.
type VMVarValueList struct {
	Value []string `json:"value"`
}

// VMNames represents the array of names to be given to newly created
// VMs, which is configures as an input for the vm terraform module
type VMNames struct {
	Value []string `json:"value"`
}

// VMPlannedValues represent the planned state of the terraform run resulting
// from the input variables and the external-ip terraform module
type VMPlannedValues struct {
	Outputs    *VMOutputs `json:"outputs"`
	RootModule TFModule   `json:"root_module"`
}

// VMOutputs represents the outputs produced by the vm terraform module
type VMOutputs struct {
	VMInfo *VMInfo `json:"vm_info"`
}

// VMInfo represent the vm information that will be created as a result of
// running the external-ip terraform module
type VMInfo struct {
	Sensitive bool `json:"sensitive"`
}
