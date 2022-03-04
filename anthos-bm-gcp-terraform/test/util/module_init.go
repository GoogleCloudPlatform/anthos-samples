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

// An InitModulePlan represents the root json object resulting from terraform
// plan on the init module
type InitModulePlan struct {
	Variables     InitVariables     `json:"variables"`
	PlannedValues InitPlannedValues `json:"planned_values"`
	Configuration InitConfiguration `json:"configuration"`
}

// InitVariables represents the variables defined within the init terraform
// module. When variables are added to the module this struct needs to be
// modified
type InitVariables struct {
	Zone                   *Variable `json:"zone"`
	PublicIP               *Variable `json:"publicIp"`
	ProjectID              *Variable `json:"project_id"`
	Username               *Variable `json:"username"`
	Hostname               *Variable `json:"hostname"`
	InitLogsFile           *Variable `json:"init_logs"`
	InitScriptPath         *Variable `json:"init_script"`
	ClusterYamlPath        *Variable `json:"cluster_yaml_path"`
	ResourcesPath          *Variable `json:"resources_path"`
	CredentialsFile        *Variable `json:"credentials_file"`
	InitCheckScript        *Variable `json:"init_check_script"`
	PublicKeyTemplatePath  *Variable `json:"pub_key_path_template"`
	PrivateKeyTemplatePath *Variable `json:"priv_key_path_template"`
	InitScriptVarsFilePath *Variable `json:"init_vars_file"`
}

// InitPlannedValues represents the planned state of the terraform run resulting
// from the input variables and the init terraform module
type InitPlannedValues struct {
	RootModule TFModule `json:"root_module"`
}

// InitConfiguration represents the configuration output in the execution plan
// resulting from the input variables and the init terraform module
type InitConfiguration struct {
	RootModule TFModule `json:"root_module"`
}
