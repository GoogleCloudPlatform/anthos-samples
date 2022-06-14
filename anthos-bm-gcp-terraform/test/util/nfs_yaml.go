// Copyright 2022 Google LLC
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

// NfsYaml represents the structure of the nfs-csi Yaml definition
type NfsYaml struct {
	Kind              *string     `yaml:"kind"`
	Metadata          Metadata    `yaml:"metadata"`
	Provisioner       *string     `yaml:"provisioner"`
	Parameters        *Parameters `yaml:"parameters"`
	Reclaimpolicy     *string     `yaml:"reclaimPolicy"`
	Volumebindingmode *string     `yaml:"volumeBindingMode"`
	Mountoptions      *[]string   `yaml:"mountOptions"`
}

// Parameters represents the parameters of the nfs-csi Yaml definition
type Parameters struct {
	Server string `yaml:"server"`
	Share  string `yaml:"share"`
}
