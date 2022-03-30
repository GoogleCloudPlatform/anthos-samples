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

// An MainModulePlan represents the root json object resulting from terraform
// plan on the main script for this specific sample
type MainModulePlan struct {
	Variables     MainVariables     `json:"variables"`
	PlannedValues MainPlannedValues `json:"planned_values"`
	Configuration MainConfiguration `json:"configuration"`
}

// MainVariables represents the variables defined for the main terraform
// script. When new variables are added to the script this struct needs to be
// modified
type MainVariables struct {
	ProjectID                  *Variable     `json:"project_id"`
	Region                     *Variable     `json:"region"`
	Zone                       *Variable     `json:"zone"`
	Network                    *Variable     `json:"network"`
	Username                   *Variable     `json:"username"`
	ABMClusterID               *Variable     `json:"abm_cluster_id"`
	AnthosServiceAccountName   *Variable     `json:"anthos_service_account_name"`
	BootDiskSize               *Variable     `json:"boot_disk_size"`
	BootDiskType               *Variable     `json:"boot_disk_type"`
	CrendetialsFile            *Variable     `json:"credentials_file"`
	ResourcesPath              *Variable     `json:"resources_path"`
	Image                      *Variable     `json:"image"`
	ImageFamily                *Variable     `json:"image_family"`
	ImageProject               *Variable     `json:"image_project"`
	MachineType                *Variable     `json:"machine_type"`
	MinCPUPlatform             *Variable     `json:"min_cpu_platform"`
	EnableNestedVirtualization *Variable     `json:"enable_nested_virtualization"`
	Tags                       *ListVariable `json:"tags"`
	AccessScope                *ListVariable `json:"access_scopes"`
	PrimaryAPIs                *ListVariable `json:"primary_apis"`
	SecondaryAPIs              *ListVariable `json:"secondary_apis"`
	InstanceCount              *MapVariable  `json:"instance_count"`
	Gpu                        *GpuVariable  `json:"gpu"`
}

// MainPlannedValues represents the planned state of the terraform run resulting
// from the input variables and the main terraform script
type MainPlannedValues struct {
	RootModule TFModule `json:"root_module"`
	Outputs    *Outputs `json:"outputs"`
}

// Outputs represents the outputs produced by the main terraform module
type Outputs struct {
	AdminVMSSH   *AdminVMSSH   `json:"admin_vm_ssh"`
	InstallCheck *InstallCheck `json:"installation_check"`
}

// AdminVMSSH represents the final output from the main terraform script with
// instructions as to how to SSH into the admin host and create a new
// ABM cluster
type AdminVMSSH struct {
	Value string `json:"value"`
}

// InstallCheck represents the final output from the main terraform script when
// it is run with the "install" modeÎ
type InstallCheck struct {
	Value string `json:"value"`
}

// MainConfiguration represents the configuration output in the execution plan
// resulting from the input variables and the main terraform script
type MainConfiguration struct {
	RootModule TFModule `json:"root_module"`
}
