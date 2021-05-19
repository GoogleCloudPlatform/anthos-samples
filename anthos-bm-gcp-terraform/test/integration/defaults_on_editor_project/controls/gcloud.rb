
project_id = attribute('project_id')
region = attribute('region')
zone = attribute('zone')

control "gcloud" do
  title "Google Compute Instances configuration"
  describe command("gcloud compute instances list --project=#{project_id} --zone=#{zone} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let!(:data) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout)
      else
        {}
      end
    end
  end
end
