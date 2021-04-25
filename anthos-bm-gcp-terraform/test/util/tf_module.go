package util

type TFModule struct {
	ChildModules  []TFModule   `json:"child_modules"`
	Resources     []TFResource `json:"resources"`
	ModuleAddress string       `json:"address"`
}

type TFResource struct {
	Type     string   `json:"type"`
	Name     string   `json:"name"`
	Provider string   `json:"provider_name"`
	Values   TFValues `json:"values"`
}

type TFValues struct {
	Name              string      `json:"name"`
	Region            string      `json:"region"`
	Zone              string      `json:"zone"`
	AddressType       string      `json:"address_type"`
	InstanceTemplate  string      `json:"source_instance_template"`
	FileName          string      `json:"filename"`
	FilePermissions   string      `json:"file_permission"`
	DirPermissions    string      `json:"directory_permission"`
	CryptoAlgorithm   string      `json:"algorithm"`
	Trigger           Trigger     `json:"triggers"`
	NetworkInterfaces []Interface `json:"network_interface"`
}

type Interface struct {
	Network string `json:"network"`
}

type Trigger struct {
	CmdBody       string `json:"create_cmd_body"`
	CmdEntrypoint string `json:"create_cmd_entrypoint"`
}
