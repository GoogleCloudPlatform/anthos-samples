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
          expect(data[x]["guestAccelerators"]).to include(
            {
              "acceleratorCount" => 1,
              "acceleratorType" => "https://www.googleapis.com/compute/v1/projects/#{project_id}/zones/us-central1-a/acceleratorTypes/nvidia-tesla-k80"
            }
          )
          x = x + 1
        end
      end
    end
  end
end
