## Creating Service Account Keys

The Google Cloud documentation for [Creating and managing Service Account Keys](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
explains well the different ways in which service account keys can be generated.

Here we explain the steps required to generate the keys using the Google Cloud
CLI (`gcloud`) tool. The same information can be found in the public documentation.
We show it here as well to make it easy for the audience of the samples to find it.

---

### Steps

The prerequisites for the [Anthos bare metal on GCE VMs with Terraform](/anthos-bm-gcp-terraform#pre-requisites)
sample requires that the `Service Account` used satisfies one of the following:
1. The Service Account has `Owner` permissions
2. The Service Account has both `Editor` and `Project IAM Admin` permissions

Thus, after creating the `Service Account` we have to add the appropriate `IAM Policies`
to the it.

#### Set environment
```sh
export GOOGLE_CLOUD_PROJECT=<YOUR_GCP_PROJECT>
export SERVICE_ACCOUNT_NAME=<SERVICE_ACC_NAME>
export PATH_TO_KEY=<LOCAL_FILE_PATH_TO_STORE_DOWNLOADED_KEY>
```

#### Create the Service Account
```sh
gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} \
    --project ${GOOGLE_CLOUD_PROJECT} \
    --description="Service Account for Anthos Bare Metal" \
    --display-name="${SERVICE_ACCOUNT_NAME}"
```

### Add IAM Policy bindings
```sh
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/owner"
```

**Or**

```sh
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/editor" \
    --role="roles/resourcemanager.projectIamAdmin"
```

### Download the Service Account key
```sh
gcloud iam service-accounts keys create ${PATH_TO_KEY} \
    --project ${GOOGLE_CLOUD_PROJECT} \
    --iam-account="${SERVICE_ACCOUNT_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
```
