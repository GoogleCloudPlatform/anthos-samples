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
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestABMEditor(t *testing.T) {
	abm := tft.NewTFBlueprintTest(t)

	abm.DefineVerify(func(assert *assert.Assertions) {
		abm.DefaultVerify(assert)
		projectID := abm.GetStringOutput("project_id")

		// pre run ssh command so that ssh-keygen can run
		runSSHCmd(t, projectID, "tfadmin@abm-ws0-001", "ls")
		runSSHCmd(t, projectID, "root@abm-ws0-001", "ls")

		vms := gcloud.Run(t, fmt.Sprintf("compute instances list --project %s", projectID)).Array()
		assert.Equal(6, len(vms), "should be 6 (1 admin-ws, 3 control plane and 2 worker nodes)")
		expectedVMs := []string{"abm-cp1-001", "abm-cp2-001", "abm-cp3-001", "abm-w1-001", "abm-w2-001", "abm-ws0-001"}
		for _, vm := range vms {
			assert.Equal("RUNNING", vm.Get("status").String(), "vm is running")
			assert.True(vm.Get("canIpForward").Bool(), "vm can canIpForward")
			assert.Contains(expectedVMs, vm.Get("name").String(), "vm is in expected list")
			assert.False(vm.Get("guestAccelerators").Exists(), "guestAccelerators are disabled")
		}

		abmInstall := runSSHCmd(t, projectID, "tfadmin@abm-ws0-001", "sudo ./run_initialization_checks.sh")
		assert.NotContains(abmInstall, "[-]", "abm installation should not have any failed setup stages")

		bmctl := runSSHCmd(t, projectID, "root@abm-ws0-001", "bmctl version")
		assert.Contains(bmctl, "bmctl version: 1.8", "bmctl version should be 1.8.x")

		docker := runSSHCmd(t, projectID, "root@abm-ws0-001", "docker version")
		dockerExpectedOP := []string{"Client: Docker Engine", "Server: Docker Engine", "API version", "Version", "linux/amd64"}
		for _, d := range dockerExpectedOP {
			assert.Contains(docker, d, fmt.Sprintf("docker version should have %s", d))
		}

		vxlan := runSSHCmd(t, projectID, "root@abm-ws0-001", "ip addr s vxlan0")
		assert.Contains(vxlan, "vxlan0: <BROADCAST,MULTICAST,UP,LOWER_UP>", "vxlan setup should have a new network device for vxlan")

	})

	abm.Test()
}

// runSSHCmd runs gcloud ssh command with ssh args and returns output
func runSSHCmd(t *testing.T, project, user, args string) string {
	commonArgs := gcloud.WithCommonArgs([]string{"--command", args, "--project", project, "--zone", "us-central1-a", "--ssh-flag=-T", "-q"})
	return gcloud.RunCmd(t, fmt.Sprintf("compute ssh %s", user), commonArgs)
}
