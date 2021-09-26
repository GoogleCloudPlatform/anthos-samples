---
gcrKeyPath: /home/abm/bm-gcr.json
sshPrivateKeyPath: /home/abm/.ssh/id_rsa
gkeConnectAgentServiceAccountKeyPath: /home/abm/bm-gcr.json
gkeConnectRegisterServiceAccountKeyPath: /home/abm/bm-gcr.json
cloudOperationsServiceAccountKeyPath: /home/abm/bm-gcr.json
---
apiVersion: v1
kind: Namespace
metadata:
  name: openstack-ns
---
apiVersion: baremetal.cluster.gke.io/v1
kind: Cluster
metadata:
  name: ${ABM_CLUSTER_NAME}
  namespace: openstack-ns
  annotations:
    baremetal.cluster.gke.io/external-cloud-provider: "true"
spec:
  type: hybrid
  anthosBareMetalVersion: ${ABM_VERSION}
  gkeConnect:
    projectID: ${PROJECT_ID}
  controlPlane:
    nodePoolSpec:
      clusterName: ${ABM_CLUSTER_NAME}
      nodes:
      - address: 10.200.0.11
  clusterNetwork:
    pods:
      cidrBlocks:
      - 10.202.0.0/16
    services:
      cidrBlocks:
      - 10.203.0.0/16
  loadBalancer:
    mode: manual
    ports:
      controlPlaneLBPort: 443
    vips:
      controlPlaneVIP: 10.200.0.101
      ingressVIP: 10.200.0.102
  clusterOperations:
    location: us-central1
    projectID: ${PROJECT_ID}
  storage:
    lvpNodeMounts:
      path: /mnt/localpv-disk
      storageClassName: node-disk
    lvpShare:
      numPVUnderSharedPath: 5
      path: /mnt/localpv-share
      storageClassName: standard
  nodeAccess:
    loginUser: abm

---
apiVersion: baremetal.cluster.gke.io/v1
kind: NodePool
metadata:
  name: node-pool-1
  namespace: openstack-ns
spec:
  clusterName: ${ABM_CLUSTER_NAME}
  nodes:
  - address: 10.200.0.12
