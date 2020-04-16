# Docker Content Trust
Tasks for Docker Content Trust

#### Tasks

- [docker-check-signature-task](#docker-check-signature-task)
- [docker-signing-task](#docker-signing-task)
- [init-docker-content-trust](#init-docker-content-trust)

## docker-check-signature-task
Checks if the required docker image signatures are present

### Inputs

#### Parameters

 - **task-pvc**: the pipeline pvc
 - **app-name**: the name of your app
 - **api-key**: the IBM Cloud API key is used to access the IBM Cloud Kubernetes service API and interact with the cluster
 - **validation-signer**: the validation signer
 - **build-signer**: the build signer
 - **registry-namespace**: the registry namespace
 - **registry-region**: the registry region
 - **vault-name**: the key protect instance name
 - **resource-group**: the resource group
 - **cluster-name**: the name of the targeted cluster
 - **region**: target region
 - **working-dir**: (Default: `/root`) the working directory
 - **mount-path**: (Default: `/artifacts`) the mount path directory
 - **volume**: (Default: `task-volume`) the volume mount name

## docker-signing-task
Signs the provided docker image

### Inputs

#### Parameters

 - **task-pvc**: the pipeline pvc
 - **app-name**: the name of your app
 - **api-key**: the IBM Cloud API key is used to access the IBM Cloud Kubernetes service API and interact with the cluster
 - **validation-signer**: the validation signer
 - **registry-namespace**: the registry namespace
 - **registry-region**: the registry region
 - **vault-name**: the key protect instance name
 - **resource-group**: the resource group
 - **cluster-name**: the name of the targeted cluster
 - **region**: target region
 - **api-endpoint**: (Default: `https://cloud.ibm.com`)the IBM cloud API endpoint
 - **working-dir**: (Default: `/root`) the working directory
 - **mount-path**: (Default: `/artifacts`) the mount path directory
 - **volume**: (Default: `task-volume`) the volume mount name
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode


## init-docker-content-trust
Creates image signing keys for DCT Image Signing tasks, and stores them in Vault

### Inputs

#### Parameters

 - **task-pvc**: the pipeline pvc
 - **api-key**: the IBM Cloud API key is used to access the IBM Cloud Kubernetes service API and interact with the cluster
 - **app-name**: the name of your app
 - **vault-name**: the key protect instance name
 - **region**: target region
 - **cluster-name**: the name of the targeted cluster
 - **registry-namespace**: the registry namespace
 - **registry-region**: the registry region
 - **resource-group**: the resource group
 - **validation-signer**: the validation signer
 - **working-dir**: (Default: `/root`) the working directory
 - **api-endpoint**: (Default: `https://cloud.ibm.com`)the IBM cloud API endpoint
 - **volume**: (Default: `task-volume`) the volume mount name
 - **mount-path**: (Default: `/artifacts`) the mount path directory

#### Outputs

Stores image signing keys in Vault

## apply-image-enforcement-policy
Applies a cluster policy whereby at deployment time, Kubernetes will enforce a siganture check condition on the specified repo image

### Inputs

#### Parameters

 - **task-pvc**: the pipeline pvc
 - **api-key**: the IBM Cloud API key is used to access the IBM Cloud Kubernetes service API and interact with the cluster
 - **app-name**: the name of your app
 - **vault-name**: the key protect instance name
 - **region**: target region
 - **cluster-name**: the name of the targeted cluster
 - **cluster-namespace**: the targeted namespace of the cluster
 - **registry-namespace**: the registry namespace
 - **registry-region**: the registry region
 - **resource-group**: the resource group
 - **validation-signer**: the validation signer
 - **working-dir**: (Default: `/root`) the working directory
 - **volume**: (Default: `task-volume`) the volume mount name
 - **mount-path**: (Default: `/artifacts`) the mount path directory
 - **helm-version** (Default: `2.16.1`) the version of helm being installed

#### Dependencies

Pulls scripts from
- https://raw.githubusercontent.com/open-toolchain/commons/master/scripts/
- https://github.com/theupdateframework/notary/releases/download/v0.6.1/notary-Linux-amd64
