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

// TFModule is the struct representation of a terraform module definition in
// JSON format, found in the output of terraform plan
type TFModule struct {
	ChildModules  []TFModule   `json:"child_modules"`
	Resources     []TFResource `json:"resources"`
	ModuleAddress string       `json:"address"`
}

// TFResource is the struct representation of a terraform resource in JSON
// format found in the output of terraform plan
type TFResource struct {
	Type     string   `json:"type"`
	Name     string   `json:"name"`
	Provider string   `json:"provider_name"`
	Values   TFValues `json:"values"`
}

// TFValues represents the common terraform resource attirbutes available in the
// JSON output of terraform plan
type TFValues struct {
	Name              string      `json:"name"`
	Region            string      `json:"region"`
	Zone              string      `json:"zone"`
	AddressType       string      `json:"address_type"`
	InstanceTemplate  string      `json:"source_instance_template"`
	FileName          string      `json:"filename"`
	FilePermissions   string      `json:"file_permission"`
	DirPermissions    string      `json:"directory_permission"`
	CryptoAlgorithm   string      `json:"algorithm"`
	Trigger           Trigger     `json:"triggers"`
	NetworkInterfaces []Interface `json:"network_interface"`
}

// Interface represents a network interface of a network resource
type Interface struct {
	Network string `json:"network"`
}

// Trigger represents a trigger attributes of a GCP gcloud resource
type Trigger struct {
	CmdBody       string `json:"create_cmd_body"`
	CmdEntrypoint string `json:"create_cmd_entrypoint"`
}
