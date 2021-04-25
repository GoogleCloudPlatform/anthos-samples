package util

type InitModulePlan struct {
	Variables     InitVariables     `json:"variables"`
	PlannedValues InitPlannedValues `json:"planned_values"`
}

type InitVariables struct {
	ProjectId              *InitVariable `json:"project_id"`
	PublicIp               *InitVariable `json:"publicIp"`
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
