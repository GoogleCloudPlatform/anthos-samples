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

package abmeditor

import (
	"fmt"
	"os"
	"os/exec"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestABMBash(t *testing.T) {
	abm := tft.NewTFBlueprintTest(t, tft.WithTFDir(t.TempDir()))
	scriptPath := "../../../anthos-bm-gcp-bash/setup_and_install_abm.sh"

	abm.DefineInit(func(assert *assert.Assertions) {})
	abm.DefineApply(func(assert *assert.Assertions) {
		cmd := exec.Command("/bin/bash", scriptPath)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		err := cmd.Run()
		assert.NoError(err)
	})

	abm.DefineVerify(func(assert *assert.Assertions) {
		abm.DefaultVerify(assert)
		projectID := abm.GetStringOutput("project_id")

		// pre run ssh command so that ssh-keygen can run
		runSSHCmd(t, projectID, "tfadmin@cluster1-abm-ws0-001", "ls")
		runSSHCmd(t, projectID, "root@cluster1-abm-ws0-001", "ls")

		vms := gcloud.Run(t, fmt.Sprintf("compute instances list --project %s", projectID)).Array()
		assert.Equal(6, len(vms), "should be 6 (1 admin-ws, 3 control plane and 2 worker nodes)")
		expectedVMs := []string{
			"cluster1-abm-cp1-001",
			"cluster1-abm-cp2-001",
			"cluster1-abm-cp3-001",
			"cluster1-abm-w1-001",
			"cluster1-abm-w2-001",
			"cluster1-abm-ws0-001",
		}
		for _, vm := range vms {
			assert.Equal("RUNNING", vm.Get("status").String(), "vm is running")
			assert.True(vm.Get("canIpForward").Bool(), "vm can canIpForward")
			assert.Contains(expectedVMs, vm.Get("name").String(), "vm is in expected list")
			assert.False(vm.Get("guestAccelerators").Exists(), "guestAccelerators are disabled")
		}

		exportCredentialsCmd := "export GOOGLE_APPLICATION_CREDENTIALS=/home/tfadmin/terraform-sa.json"

		abmInstall := runSSHCmd(t, projectID, "tfadmin@cluster1-abm-ws0-001", fmt.Sprintf("%s && sudo -E ./run_initialization_checks.sh", exportCredentialsCmd))
		assert.NotContains(abmInstall, "[-]", "gce setup for abm installation should not have any failed stages")

		bmctl := runSSHCmd(t, projectID, "root@cluster1-abm-ws0-001", "bmctl version")
		assert.Contains(bmctl, "bmctl version: 1.13.0", "bmctl version should be 1.13.0")

		docker := runSSHCmd(t, projectID, "root@cluster1-abm-ws0-001", "docker version")
		dockerExpectedOP := []string{"Client: Docker Engine", "Server: Docker Engine", "API version", "Version", "linux/amd64"}
		for _, d := range dockerExpectedOP {
			assert.Contains(docker, d, fmt.Sprintf("docker version should have %s", d))
		}

		vxlan := runSSHCmd(t, projectID, "root@cluster1-abm-ws0-001", "ip addr s vxlan0")
		assert.Contains(vxlan, "vxlan0: <BROADCAST,MULTICAST,UP,LOWER_UP>", "vxlan setup should have a new network device for vxlan")

		clusterConfigCreatedMsg := "Created config: bmctl-workspace/cluster1/cluster1.yaml"
		bootstrapClusterOKMsg := "Creating bootstrap cluster... OK"
		depInstallOKMsg := "Installing dependency components... OK"
		kubeConfigCreatedMsg := "kubeconfig of cluster being created is present at bmctl-workspace/cluster1/cluster1-kubeconfig"
		clusterReadyOKMsg := "Waiting for cluster to become ready OK"
		nodePoolOKMsg := "Waiting for node pools to become ready OK"
		deleteBootstrapClusterOKMsg := "Deleting bootstrap cluster... OK"

		createClusterConfig := runSSHCmd(t, projectID, "tfadmin@cluster1-abm-ws0-001", fmt.Sprintf("%s && sudo -E bmctl create config -c cluster1", exportCredentialsCmd))
		assert.Contains(createClusterConfig, clusterConfigCreatedMsg, "bmctl create should successfully create the config file")

		runSSHCmd(t, projectID, "tfadmin@cluster1-abm-ws0-001", fmt.Sprintf("%s && sudo -E cp ~/cluster1.yaml bmctl-workspace/cluster1", exportCredentialsCmd))
		listClusterConfigFile := runSSHCmd(t, projectID, "tfadmin@cluster1-abm-ws0-001", "sudo ls bmctl-workspace/cluster1")
		assert.Contains(listClusterConfigFile, "cluster1.yaml", "cluster configuration file should be in the correct workspace directory")

		installABM := runSSHCmd(t, projectID, "tfadmin@cluster1-abm-ws0-001", fmt.Sprintf("%s && sudo -E bmctl create cluster -c cluster1", exportCredentialsCmd))
		assert.Contains(installABM, bootstrapClusterOKMsg, "abm installation should create a bootstrap cluster")
		assert.Contains(installABM, depInstallOKMsg, "abm installation should install necessary dependencies")
		assert.Contains(installABM, kubeConfigCreatedMsg, "abm installation should create the cluster configuration file")
		assert.Contains(installABM, clusterReadyOKMsg, "abm installation should ensure that the cluster is ready")
		assert.Contains(installABM, nodePoolOKMsg, "abm installation should setup the nodepools")
		assert.Contains(installABM, deleteBootstrapClusterOKMsg, "abm installation should delete the bootstrap cluster in the end")
	})

	abm.Test()
}

// runSSHCmd runs gcloud ssh command with ssh args and returns output
func runSSHCmd(t *testing.T, project, user, args string) string {
	commonArgs := gcloud.WithCommonArgs([]string{"--command", args, "--project", project, "--zone", "us-central1-a", "--ssh-flag=-T", "-q"})
	return gcloud.RunCmd(t, fmt.Sprintf("compute ssh %s", user), commonArgs)
}
