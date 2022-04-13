## Creating a new Actions runner

The actions runners for this repository are hosted in the `anthos-gke-samples-ci` project. If you want to add new runners _(for capacity purposes or upgrading tools installed in the runners)_ you can follow the guidelines below:

- Runners are created in the `anthos-gke-samples-ci` project in GCP
- The runner VMs should:
  - be at least n1-standard-4
  - have atleast 50GB persistent disk
  - use custom service account with only `read` permissions to the `Compute Engine API`

- Once the VM for the runner is created
  - SSH into new VM through Google Cloud Console
  - Follow the instructions to add a new runner by clicking `Add runner` in the [Actions settings](https://github.com/GoogleCloudPlatform/anthos-samples/settings/actions/runners) page
  - Add a label of the form `runner-<month>-<year>` _(e.g: runner-july-21)_ to te newly created runner _(you can do this whilst following the setup guide from inside the VM or do it in the [runners](https://github.com/GoogleCloudPlatform/anthos-samples/settings/actions/runners) page after you have authenticated the VM)_
  - Start GitHub Actions as a background service:
    ```
    sudo ~/actions-runner/svc.sh install ; sudo ~/actions-runner/svc.sh start
    ```
  - Install repository-specific dependencies using the [gh_runner_dependencies.sh](./gh_runner_dependencies.sh) file:
    ```
    wget -O - https://raw.githubusercontent.com/GoogleCloudPlatform/anthos-samples/main/.github/gh_runner_dependencies.sh | bash
    ```
  > **Note:** Once the script is complete you should see some extra steps printed out. Those steps must also be executed to complete the runner setup

- You might have to restart the VM for the changes to take effect

- Finally open a PR with the following changes:
  - Update the [workflow files](./workflows) to use the new runner label _(e.g: runner-jan-2031 as used above)_ for the `runs-on` directive for Github actions
- Verify that the actions run on the new runner without any issues

