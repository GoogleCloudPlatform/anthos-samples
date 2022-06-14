---
gcrKeyPath: /root/bm-gcr.json
sshPrivateKeyPath: /root/.ssh/id_rsa
gkeConnectAgentServiceAccountKeyPath: /root/bm-gcr.json
gkeConnectRegisterServiceAccountKeyPath: /root/bm-gcr.json
cloudOperationsServiceAccountKeyPath: /root/bm-gcr.json
---
apiVersion: v1
kind: Namespace
metadata:
  name: ${clusterId}-ns
---
apiVersion: baremetal.cluster.gke.io/v1
kind: Cluster
metadata:
  name: ${clusterId}
  namespace: ${clusterId}-ns
spec:
  type: hybrid
  anthosBareMetalVersion: 1.11.1
  gkeConnect:
    projectID: ${projectId}
  controlPlane:
    nodePoolSpec:
      clusterName: ${clusterId}
      nodes:
      %{ for ip in controlPlaneIps ~}
- address: ${ip}
      %{ endfor }
  clusterNetwork:
    pods:
      cidrBlocks:
      - 192.168.0.0/16
    services:
      cidrBlocks:
      - 172.26.232.0/24
  loadBalancer:
    mode: manual
    ports:
      controlPlaneLBPort: 443
    vips:
      controlPlaneVIP: ${controlPlaneVIP}
      ingressVIP: ${ingressVIP}
  clusterOperations:
    # might need to be this location
    location: us-central1
    projectID: ${projectId}
  storage:
    lvpNodeMounts:
      path: /mnt/localpv-disk
      storageClassName: node-disk
    lvpShare:
      numPVUnderSharedPath: 5
      path: /mnt/localpv-share
      storageClassName: local-shared
---
apiVersion: baremetal.cluster.gke.io/v1
kind: NodePool
metadata:
  name: node-pool-1
  namespace: ${clusterId}-ns
spec:
  clusterName: ${clusterId}
  nodes:
  %{ for ip in workerNodeIps ~}
- address: ${ip}
  %{ endfor }
