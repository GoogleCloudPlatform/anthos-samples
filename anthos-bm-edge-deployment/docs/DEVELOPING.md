## Developing with Ansible

This section is 100% optional and is intended to provide information about how to contribute to this project.  This project is primarly based on Ansible, which has some challenges when developing against a physical server. Lucily, there is Molecule, a tool that established a build lifecycle and supports development using ephemeral Docker containers.

### Using Molecule

If you wish to use Molecule to develop the roles, install the following:

```bash
python -m pip install --user "molecule[ansible,docker,lint,gce]"
# not 100% sure that the above installs the gce provisioner for molecule, so repeat just in case
pip install molecule-gce
```

### Creating a new module

1. Navigate to the `roles/` folder.

1. Create a new module
    ```bash
    molecule init role
    ```
1. Modify the `README.md` with appropriate details

1. Use `setup-kvm` or `google-tools` as reference for setting up Molecule (see folder `molecule/` to see docker config)

1. Remove any un-used folders

### Testing Role in isolation

1. Navigate to the role folder

1. Verify configuration has been setup for Molecule

    > NOTE: Sometimes the Docker image needs to be pulled prior to running tests/converge

1. Run `moleclue converge` to test
