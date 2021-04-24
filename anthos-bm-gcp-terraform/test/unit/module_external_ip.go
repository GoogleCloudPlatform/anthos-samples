package unit

type ExternalIpPlan struct {
	Variables     Variables     `json:"variables"`
	PlannedValues PlannedValues `json:"planned_values"`
}

type Variables struct {
	IPNames *IPNames `json:"ip_names"`
	Region  *Region  `json:"region"`
}

type Region struct {
	Value string `json:"value"`
}

type IPNames struct {
	Value []string `json:"value"`
}

type PlannedValues struct {
	Outputs    Outputs    `json:"outputs"`
	RootModule RootModule `json:"root_module"`
}

type Outputs struct {
	IPS *IPS `json:"ips"`
}

type IPS struct {
	Sensitive bool `json:"sensitive"`
}

type RootModule struct {
	Resources []Resource `json:"resources"`
}

type Resource struct {
	Type     string `json:"type"`
	Name     string `json:"name"`
	UniqueId string `json:"index"`
	Provider string `json:"provider_name"`
	Values   Values `json:"values"`
}

type Values struct {
	Name        string `json:"name"`
	Region      string `json:"region"`
	AddressType string `json:"address_type"`
}
