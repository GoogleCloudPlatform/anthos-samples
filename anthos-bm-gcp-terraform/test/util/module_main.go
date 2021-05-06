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
	ProjectID                *Variable     `json:"project_id"`
	Region                   *Variable     `json:"region"`
	Zone                     *Variable     `json:"zone"`
	Network                  *Variable     `json:"network"`
	Username                 *Variable     `json:"username"`
	ABMClusterID             *Variable     `json:"abm_cluster_id"`
	AnthosServiceAccountName *Variable     `json:"anthos_service_account_name"`
	BootDiskSize             *Variable     `json:"boot_disk_size"`
	BootDiskType             *Variable     `json:"boot_disk_type"`
	CrendetialsFile          *Variable     `json:"credentials_file"`
	ImageFamily              *Variable     `json:"image_family"`
	ImageProject             *Variable     `json:"image_project"`
	MachineType              *Variable     `json:"machine_type"`
	MinCPUPlatform           *Variable     `json:"min_cpu_platform"`
	Tags                     *ListVariable `json:"tags"`
	AccessScope              *ListVariable `json:"access_scopes"`
	PrimaryAPIs              *ListVariable `json:"primary_apis"`
	SecondaryAPIs            *ListVariable `json:"secondary_apis"`
	InstanceCount            *MapVariable  `json:"instance_count"`
}

// MainPlannedValues represents the planned state of the terraform run resulting
// from the input variables and the main terraform script
type MainPlannedValues struct {
	RootModule TFModule `json:"root_module"`
}

// MainConfiguration represents the configuration output in the execution plan
// resulting from the input variables and the main terraform script
type MainConfiguration struct {
	RootModule TFModule `json:"root_module"`
}
