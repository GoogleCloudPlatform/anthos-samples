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

// ClusterYaml represents the structure of the Yaml definition that is to be
// copied over to the admin host, which will be eventually used to create the
// Anthos Baremetal cluster
type ClusterYaml struct {
	Kind     *string  `yaml:"kind"`
	Metadata Metadata `yaml:"metadata"`
	Spec     *Spec    `yaml:"spec"`
}

// Metadata represents the the metadata definition on the different resource
// types used on the cluster Yaml describing the Anthos Baremetal cluster. This
// struct includes a union of all possible metadata values for different kings
// of resources (i.e: Nodepools, Cluster, Namespace)
type Metadata struct {
	Name      string `yaml:"name"`
	Namespace string `yaml:"namespace"`
}

// Spec represents the the spec definition on the different resource types
// used on the cluster Yaml describing the Anthos Baremetal cluster. This
// struct includes a union of all possible spec values for different kings
// of resources (i.e: Nodepools, Cluster, Namespace)
type Spec struct {
	ClusterName       *string            `yaml:"clusterName"`
	ControlPlane      *ControlPlane      `yaml:"controlPlane"`
	GkeConnect        *GkeConnect        `yaml:"gkeConnect"`
	ClusterOperations *ClusterOperations `yaml:"clusterOperations"`
	Nodes             *[]Node            `yaml:"nodes"`
}

// GkeConnect represents the gkeConnect attribute in the spec definition for
// the resource kind Cluster in the Yaml for the Anthos Baremetal cluster
type GkeConnect struct {
	ProjectID string `yaml:"projectID"`
}

// ClusterOperations represents the clusterOperations attribute in the spec
// definition for the resource kind Cluster in the Yaml for the
// Anthos Baremetal cluster
type ClusterOperations struct {
	ProjectID string `yaml:"projectID"`
}

// Node represents a single node definition in the spec definition for the
// resource kind Cluster and Nodepools in the Yaml for the
// Anthos Baremetal cluster
type Node struct {
	Address string `yaml:"address"`
}

// ControlPlane represents the controlPlane attribute in the spec definition
// for the resource kind Cluster in the Yaml for the Anthos Baremetal cluster
type ControlPlane struct {
	NodePoolSpec *NodePoolSpec `yaml:"nodePoolSpec"`
}

// NodePoolSpec represents the nodePoolSpec attribute in the spec.controlPlane
// definition for the resource kind Cluster in the Yaml for the
// Anthos Baremetal cluster
type NodePoolSpec struct {
	ClusterName string  `yaml:"clusterName"`
	Nodes       *[]Node `yaml:"nodes"`
}
