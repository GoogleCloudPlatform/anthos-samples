# Overview

This document describes how to provision a hardware based machine such as a NUC or Dell R-series.

There are two options to provision a machine, an automated installation process or a manual installation (both via a USB). PXE installations are out-of-scope for this project, but is competely possible for an advanced user. Additionally, "golden images" would be another recommended approach to reduce provisioning time, but also out of scope.

## Step 1 (Option 1)- Automated Provisioning (preferred)

1. Clone [https://github.com/mike-ensor/ubuntu-20-04-autoinstall](https://github.com/mike-ensor/ubuntu-20-04-autoinstall)
1. Create a file called `pub_keys` and add the contents of your public key into this file (multiple public keys can be added on each line). This will automatically transfer the public keys into the `abm-admin` user's `authorized_keys` file allowing passwordless SSH.

    > NOTE: Never commit this file to a repository. By default, this file is ignored in .gitignore

    ```bash
    cat ~/.ssh/nucs.pub > ./pub-keys
    ```
1. Run the following command from that folder:
    > NOTE: `-H` specifies a hostname and generates configuration specific to that hostname. Each ISO will be unique to the host name chosen.

    > NOTE: Possibly create a loop on this, or just run `3n` of these (1..3 or 1..6) as physical hardware is available for your use case.
    ```bash
    ./build_iso.sh -u abm-admin -H nuc-1 -P -F /some/location/nuc-1.iso
    ```
1. Flash the created ISO to a USB stick (Rufus, Balena, etc)
1. Insert USB into target machine
1. Reboot and enter Boot preference tab (`F7`)
    1. Select the USB stick option
    1. Save and continue (machine will reboot)
1. Wait for auto-installer to complete (15-20 min)
    1. Watch for machine to reboot, pull out the USB stick after that
    1. Default password (at time of writing this doc) is `troubled-marble-150`

## Step 1 (Option 2) - Manually provisioning Ubuntu (Advanced users only)

1. Create a bootable USB stick with Ubuntu 20.04 LTS
    * USB Boot Stick (Ubuntu option) -- https://ubuntu.com/tutorials/create-a-usb-stick-on-ubuntu#1-overview
    * USB Boot Stick (Windows option) -- https://ubuntu.com/tutorials/create-a-usb-stick-on-windows#1-overview
    * USB Boot Stick (MacOS option) -- https://ubuntu.com/tutorials/create-a-usb-stick-on-macos#1-overview

    > NOTE: 20.10 will NOT work, only 18.04 LTS or 20.04 LTS is supported

1. Insert USB and install Ubuntu 20.04 LTS

    > NOTE: USB may need to adjust UEFI/BIOS to boot from USB drive. Depending on BIOS/UEFI, this is found in the "boot" menu. For some BIOS, `F7` pressed during initial boot provides a quick `boot option` without editing the entire BIOS

    1. During setup, select a hostname using some convention. In this repo, `nuc-x` is the convention. For example, Store 1's NUC would be hostname `nuc-1`, Store 2 would be `nuc-2`, etc.
    1. (Optional, but recommended) If your router can reserve hostname->IP, reserve an IP but let Ubuntu use DHCP to acquire IP addresses
    1. Create a new `user` called `abm-admin` and set a password (both will be used to access the target box). It's best to keep the same username and password for all *target machines* for automation purposes.
        > Remember this `abm-admin` and the `password`
        > NOTE: Recommended to use `abm-admin` and `trusted-marble-150` as the username/password to match the automated process. Deviating may cause issues that an advanced user will need to address.
    1. Install "OpenSSH" and no other software during initial setup
    1. Double check, you only set "hostname", created a user (use the same username and password for all machines) and you added OpenSSH
    1. Reboot as prompted.
1. Login at the prompt with the *username* and *password* created durin the setup. If any errors, restart process
1. Copy SSH keys to all target machines. This will copy the public key created in the `abm-admin`'s `authorized_keys` file for passwordless SSH (setup later)

    ```bash
    ssh-copy-id -i ~/.ssh/nucs abm-admin@nuc-1 # repeat for nuc-2, nuc-3...
    ```
    * Use the password and user (abm-admin) created in step 1.
    * Repeat for all machines

### Verify Provisioning

1. At the completion of this provisioning (automated or manual), you should be able to SSH into each of the target machine(s) using the same `username` (hopefully `abm-admin`) and `password` established in the setup using the hostname convention `nuc-x`. Some domains/routers will automatically postfix `.lan` or `.localdomain`, so try these options if `nuc-x` does not resolve.
    * Example
        ```bash
        # Prompted for password (enter `troubled-marble-150` or your password)
        ssh -i ~/.ssh/nucs abm-admin@nuc-1
        ```
