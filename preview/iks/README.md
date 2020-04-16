# IBM Kubernetes Service
Tasks for IKS

#### Tasks

- [fetch-iks-cluster-config](#fetch-iks-cluster-config)
- [deploy-to-cluster](#deploy-to-cluster)
- [kubernetes-contextual-execution](#kubernetes-contextual-execution)

## fetch-iks-cluster-config
Fetch IKS cluster config

### Inputs

#### Parameters

 - **task-pvc**: the pipeline pvc
 - **cluster-name**: the targeted cluster
 - **cluster-region**: region of targeted cluster
 - **ibmcloud-api-key**: The IBM Cloud API key
 - **ibmloud-api**: (Default: `https://cloud.ibm.com`)the IBM cloud API endpoint
 - **cluster-pipeline-resources-directory-fallback**: (Default: `.tekton-cluster-pipeline-resources`) directory in the task-pvc that will be used as a fallback mechanism to store the kubeconfig file
 - **kube-api-server-accessible**: (Default: `false`) indicates if the kubeAPIServer is exposed which is not the case for IBM Cloud Public Shared Workers (Calico network policy). If 'true', the task is trying to update the Cluster Pipeline Resources definition with the appropriate information. When 'false', the fallback mechanism (copy file(s)) is used.
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Resources

- **cluster**

### Outputs

Saves Kubeconfig file(s) to `/artifacts/$(inputs.params.cluster-pipeline-resources-directory-fallback)/$(inputs.params.cluster-name)`

#### Resources

- **cluster**

## deploy-to-cluster
Deploy to a given cluster

### Inputs

#### Parameters

- **task-pvc**: pipeline pvc name place holder
- **repository**: The git repo
- **revision**: the branch for the git repo
- **cluster-name**: The IBM Cloud cluster name
- **cluster-region**: The IBM Cloud region for your cluster
- **cluster-namespace**: (Default: `default`) The IBM Cloud cluster namespace
- **ibmcloud-api-key**: The IBM Cloud API key is used to access the IBM Cloud Kubernetes Service API and interact with the cluster. You can obtain your API key with 'bx iam api-key-create' or via the console at https://cloud.ibm.com/iam#/apikeys by clicking **Create API key** (Each API key only can be viewed once).
- **ibmcloud-api**: (Default: `https://cloud.ibm.com`) the ibmcloud api endpoint
- **deployment-file**: (Default: `/artifacts/deployment.yml`) Kubernetes Deployment resource file to use for deploy
- **allow-create-route**:  (Default: `"false"`) Allow the task to create a Route resource (if there is none) to access the deployed app
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Resources

- **deployment-file** (Default: "/artifacts/deployment.yml") a Deployment and Service resource yaml in your application repo, that will be applied on the cluster. See the [one-pipeline/hello-compliance-app](https://github.ibm.com/one-pipeline/hello-compliance-app/blob/master/deployment.yml) for example.

## kubernetes-contextual-execution
Executes a user defined script within the context of the kubernetes configuration

### Inputs

#### Parameters

- **task-pvc**: the task pvc, valid for the lifetime of the pipelinerun
- **task-pvc-mountpath**: (Default: `/artifacts`) path where the task pvc is mounted
- **clusterPipelineResourcesDirectory**: (Default: `/workspace`) directory in which the kubeconfig file(s) for clusterPipelineResources are available
- **script**: (Default: `kubectl version`) the bash snippet to execute
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

### Resources

- **cluster**: the target cluster acquired in the previous task

## Usage
Task usage inside a pipeline

```yaml
    - name: pipeline-1-kubectl-task
      runAfter: [fetch-iks-cluster-config]
      taskRef:
        name: kubernetes-contextual-execution
      params:
        - name: task-pvc
          value: $(params.pipeline-pvc)
        - name: task-pvc-mountpath
          value: /pipelinerun
        - name: clusterPipelineResourcesDirectory
          value: /pipelinerun/.tekton-clusters
        - name: script
          value: |
            echo "** Here is the kubectl version:"
            kubectl version
            echo "** Here is the kubectl cluster-info:"
            kubectl cluster-info
            echo "** Here are the kubectl namespaces:"
            kubectl get namespaces
      resources:
        inputs:
          - name: cluster
            resource: target-cluster
            from:
              - fetch-iks-cluster-config
```
