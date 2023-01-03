# Anthos + Crossplane Demo
This is a demo of using Anthos & Crossplane to deploy and Manage GKE, EKS, and AKS via Anthos. You can also choose to setup GKE on AWS or Azure
## Install Crossplane

```sh

helm repo add crossplane-stable \
    https://charts.crossplane.io/stable

helm repo update

helm upgrade --install \
    crossplane crossplane-stable/crossplane \
    --namespace crossplane-system \
    --create-namespace \
    --wait
```
## GCP Setup
### Create Secrets
You will need to create a service account in your GCP project and [export the JSON token to a file](https://cloud.google.com/iam/docs/creating-managing-service-account-keys). In this example the file is named gcp-creds.json. 

```sh
kubectl --namespace crossplane-system \
    create secret generic gcp-creds \
    --from-file creds=secrets/gcp-creds.json
```
Install the GCP provider
```sh
kubectl crossplane install provider \
    crossplane/provider-gcp:v0.21.0
```

Edit the providers/gcp-provider-config.yaml to include your project number
```sh
  projectNumber: "Your Project Number"
``` 
Apply the configurations
```sh
kubectl apply -f providers/gcp-provider-config.yaml
kubectl apply -f compositions/cluster-gcp-gke.yaml
kubectl apply -f package/xrd.yaml 
```
#### Create a GKE Cluster on GCP
Apply the claim
```sh
kubectl apply -f claims/cluster-gke-gcp.yaml
```

#### Troubleshooting & Status of Sync
```sh
kubectl get events -n default --sort-by={'lastTimestamp'}
```