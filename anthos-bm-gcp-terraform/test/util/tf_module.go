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
	Type         string          `json:"type"`
	Name         string          `json:"name"`
	Provider     string          `json:"provider_name"`
	Values       TFValues        `json:"values"`
	Provisioners []TFProvisioner `json:"provisioners"`
}

// TFValues represents the common terraform resource attributes available in the
// JSON output of terraform plan. Note that this is a union of all possible
// values for any modules used in this script
type TFValues struct {
	Name                    string                    `json:"name"`
	Index                   string                    `json:"index"`
	Region                  string                    `json:"region"`
	Zone                    string                    `json:"zone"`
	AddressType             string                    `json:"address_type"`
	InstanceTemplate        string                    `json:"source_instance_template"`
	FileName                string                    `json:"filename"`
	FilePermissions         string                    `json:"file_permission"`
	DirPermissions          string                    `json:"directory_permission"`
	CryptoAlgorithm         string                    `json:"algorithm"`
	Content                 string                    `json:"content"`
	Project                 string                    `json:"project"`
	ImageFamily             string                    `json:"family"`
	MachineType             string                    `json:"machine_type"`
	MinCPUPlatform          string                    `json:"min_cpu_platform"`
	AdvancedMachineFeatures []AdvancedMachineFeatures `json:"advanced_machine_features"`
	Service                 string                    `json:"service"`
	CanIPForward            bool                      `json:"can_ip_forward"`
	Trigger                 Trigger                   `json:"triggers"`
	Tags                    []string                  `json:"tags"`
	Disk                    []Disk                    `json:"disk"`
	ServiceAccount          []ServiceAccount          `json:"service_account"`
	NetworkInterfaces       []Interface               `json:"network_interface"`
	Gpu                     *Gpu                      `json:"gpu"`
}

// TFProvisioner represents the provisioners configured in the terraform output
// resulting from the terraform plan
type TFProvisioner struct {
	Type string `json:"type"`
}

// Interface represents a network interface of a network resource
type Interface struct {
	Network string `json:"network"`
}

// ServiceAccount represents a service account associated to an instance
// template resource
type ServiceAccount struct {
	Scopes []string `json:"scopes"`
}

// Disk represents a storage disk associated to an instance template resource
type Disk struct {
	Type string `json:"disk_type"`
	Size int    `json:"disk_size_gb"`
}

// AdvancedMachineFeatures represents advanced machine features associated to an instance template resource
type AdvancedMachineFeatures struct {
	EnableNestedVirtualization bool `json:"enable_nested_virtualization"`
}

// Trigger represents a trigger attributes of a GCP gcloud resource
type Trigger struct {
	CmdBody       string `json:"create_cmd_body"`
	CmdEntrypoint string `json:"create_cmd_entrypoint"`
}

// Variable represents an instance of a single terraform input variable
type Variable struct {
	Value string `json:"value"`
}

// ListVariable represents an instance of a single terraform input variable
// which is of type list
type ListVariable struct {
	Value []string `json:"value"`
}

// MapVariable represents an instance of a single terraform input variable
// which is of type map
type MapVariable struct {
	Value map[string]int `json:"value"`
}

// GpuVariable represents an instance of a variable carrying Gpu information
type GpuVariable struct {
	Value Gpu `json:"value"`
}

// Gpu represents an instance of a single terraform input which holds
// information about a Gpu instance to be associated to a VM
type Gpu struct {
	Count int    `json:"count"`
	Type  string `json:"type"`
}
