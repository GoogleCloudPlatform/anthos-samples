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

type ExternalIpPlan struct {
	Variables     IPVariables     `json:"variables"`
	PlannedValues IPPlannedValues `json:"planned_values"`
}

type IPVariables struct {
	IPNames *IPNames  `json:"ip_names"`
	Region  *IPRegion `json:"region"`
}

type IPRegion struct {
	Value string `json:"value"`
}

type IPNames struct {
	Value []string `json:"value"`
}

type IPPlannedValues struct {
	Outputs    IPOutputs `json:"outputs"`
	RootModule TFModule  `json:"root_module"`
}

type IPOutputs struct {
	IPS *IPS `json:"ips"`
}

type IPS struct {
	Sensitive bool `json:"sensitive"`
}
