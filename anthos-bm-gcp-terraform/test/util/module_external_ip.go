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
