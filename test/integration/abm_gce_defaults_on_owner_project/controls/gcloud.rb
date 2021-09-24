# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


project_id = attribute('project_id')
bmctl_version_check = attribute('bmctl_version_check')
docker_version_check = attribute('docker_version_check')
vxlan_check = attribute('vxlan_check')
ssh_as_tfadmin = attribute('ssh_as_tfadmin')
abm_install_check = attribute('abm_install_check')
# pre run ssh command so that ssh-keygen can run
%x( #{bmctl_version_check} )
%x( #{ssh_as_tfadmin} )

control "gcloud" do
  title "Google Compute Instances configuration"

  describe command("gcloud compute instances list --project=#{project_id} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let!(:data) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "number of nodes" do
      it "should be 6 (1 admin-ws, 3 control plane and 2 worker nodes) " do
        expect(data.length).to eq 6
      end
    end

    describe "VM attributes" do
      it "should have all the default values" do
        x = 0
        while x < 6
          expect(data[x]).to include(
            "status" => "RUNNING"
          )

          expect(data[x]).to include(
            "canIpForward" => true
          )

          expect([
            "abm-cp1-001", "abm-cp2-001", "abm-cp3-001",
            "abm-w1-001", "abm-w2-001", "abm-ws0-001"]).to include(
              data[x]["name"]
            )

          expect(data[x]).not_to include("guestAccelerators")
          x = x + 1
        end
      end
    end
  end

  describe command(abm_install_check) do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }
    let!(:data) do
      if subject.exit_status == 0
        subject.stdout
      else
        ""
      end
    end
    describe "abm installation setup" do
      it "should not have any failed setup stages" do
        expect(data).not_to include("[-]")
      end
    end
  end

  describe command(bmctl_version_check) do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }
    let!(:data) do
      if subject.exit_status == 0
        subject.stdout
      else
        ""
      end
    end
    describe "bmctl version" do
      it "should be 1.8.x" do
        expect(data).to include("bmctl version: 1.8")
      end
    end
  end

  describe command(docker_version_check) do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }
    let!(:data) do
      if subject.exit_status == 0
        subject.stdout
      else
        ""
      end
    end
    describe "docker version" do
      it "should have Version, API Version for Server and Client" do
        expect(data).to include("Client: Docker Engine")
        expect(data).to include("Server: Docker Engine")
        expect(data).to include("API version")
        expect(data).to include("Version")
        expect(data).to include("linux/amd64")
      end
    end
  end

  describe command(vxlan_check) do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }
    let!(:data) do
      if subject.exit_status == 0
        subject.stdout
      else
        ""
      end
    end
    describe "vxlan setup" do
      it "should have a new network device for vxlan" do
        expect(data).to include("vxlan0: <BROADCAST,MULTICAST,UP,LOWER_UP>")
      end
    end
  end

end
