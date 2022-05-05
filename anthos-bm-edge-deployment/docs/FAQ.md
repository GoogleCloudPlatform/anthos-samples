## Frequently asked questions 


### How can I access a GUI or a service endpoint of a POD running in the ABM cluster without exposing with a load balancer  ?

1st ssh into the cnuc1:

1. ssh into `cnuc-1` as abm-admin user.

1. Port forward with bind address . Do this as root of you want port 80 (standard port). Otherwise use different port 
    ```bash
    kubectl -n longhorn-system port-forward --address 0.0.0.0 longhorn-ui-5b864949c4-plwwg 80:8000
    ```
1. Setup a `firewall rule` to allow port 80 or whichever port you used in earlier step 

1. Find the public IP of the cnuc-1 and access the port like `http://cnuc-1-external-ip:port` 


```bash
python -m pip install --user "molecule[ansible,docker,lint,gce]"
# not 100% sure that the above installs the gce provisioner for molecule, so repeat just in case
pip install molecule-gce
```

### Any new question 

1. Navigate to the `roles/` folder.
