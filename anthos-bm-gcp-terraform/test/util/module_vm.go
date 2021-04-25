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
