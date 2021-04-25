package unit

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
	Outputs    IPOutputs    `json:"outputs"`
	RootModule IPRootModule `json:"root_module"`
}

type IPOutputs struct {
	IPS *IPS `json:"ips"`
}

type IPS struct {
	Sensitive bool `json:"sensitive"`
}

type IPRootModule struct {
	Resources []IPResource `json:"resources"`
}

type IPResource struct {
	Type     string   `json:"type"`
	Name     string   `json:"name"`
	UniqueId string   `json:"index"`
	Provider string   `json:"provider_name"`
	Values   IPValues `json:"values"`
}

type IPValues struct {
	Name        string `json:"name"`
	Region      string `json:"region"`
	AddressType string `json:"address_type"`
}
