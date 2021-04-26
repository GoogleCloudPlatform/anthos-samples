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

type VMInstancePlan struct {
	Variables     VMVariables     `json:"variables"`
	PlannedValues VMPlannedValues `json:"planned_values"`
}

type VMVariables struct {
	Region           *VMVarValue     `json:"region"`
	Network          *VMVarValue     `json:"network"`
	Names            *VMVarValueList `json:"vm_names"`
	InstanceTemplate *VMVarValue     `json:"instance_template"`
}

type VMVarValue struct {
	Value string `json:"value"`
}

type VMVarValueList struct {
	Value []string `json:"value"`
}

type VMNames struct {
	Value []string `json:"value"`
}

type VMPlannedValues struct {
	Outputs    VMOutputs `json:"outputs"`
	RootModule TFModule  `json:"root_module"`
}

type VMOutputs struct {
	VMInfo *VMInfo `json:"vm_info"`
}

type VMInfo struct {
	Sensitive bool `json:"sensitive"`
}
