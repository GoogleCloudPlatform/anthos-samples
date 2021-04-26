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

type InitModulePlan struct {
	Variables     InitVariables     `json:"variables"`
	PlannedValues InitPlannedValues `json:"planned_values"`
}

type InitVariables struct {
	ProjectID              *InitVariable `json:"project_id"`
	PublicIP               *InitVariable `json:"publicIp"`
	Zone                   *InitVariable `json:"zone"`
	Username               *InitVariable `json:"username"`
	Hostname               *InitVariable `json:"hostname"`
	InitLogsFile           *InitVariable `json:"init_logs"`
	InitScriptPath         *InitVariable `json:"init_script"`
	PreflightsScript       *InitVariable `json:"preflight_script"`
	ClusterYamlFile        *InitVariable `json:"credentials_file"`
	InitScriptVarsFilePath *InitVariable `json:"init_vars_file"`
	ClusterYamlPath        *InitVariable `json:"cluster_yaml_path"`
	PublicKeyTemplatePath  *InitVariable `json:"pub_key_path_template"`
	PrivateKeyTemplatePath *InitVariable `json:"priv_key_path_template"`
}

type InitVariable struct {
	Value string `json:"value"`
}

type InitPlannedValues struct {
	RootModule TFModule `json:"root_module"`
}
