package unit

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
	Outputs    VMOutputs    `json:"outputs"`
	RootModule VMRootModule `json:"root_module"`
}

type VMOutputs struct {
	VMInfo *VMInfo `json:"vm_info"`
}

type VMInfo struct {
	Sensitive bool `json:"sensitive"`
}

type VMRootModule struct {
	VMChildModules []VMChildModule `json:"child_modules"`
}

type VMChildModule struct {
	Resources     []VMResource `json:"resources"`
	ModuleAddress string       `json:"address"`
}

type VMResource struct {
	Type     string   `json:"type"`
	Name     string   `json:"name"`
	Provider string   `json:"provider_name"`
	Values   VMValues `json:"values"`
}

type VMValues struct {
	Name              string      `json:"name"`
	Zone              string      `json:"zone"`
	Region            string      `json:"region"`
	InstanceTemplate  string      `json:"source_instance_template"`
	NetworkInterfaces []Interface `json:"network_interface"`
}

type Interface struct {
	Network string `json:"network"`
}
