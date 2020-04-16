# ServiceNow Change management

Tasks for working with ServiceNow Change Management

#### Tasks

- [create-change-request](#create-change-request)
- [check-change-request-approval](#check-change-request-approval)
- [close-change-request](#close-change-request)


## create-change-request

Create a Change Request in ServiceNow.

Right now, data for the Change Request is collected and compiled from two sources:
* fields filled out in the Pull Request that initiated deployment - [see the PR template example]('/preview/servicenow/pull_request_template.md')
* git commit history between the latest built image release in the cluster and the current image

**This will most likely to change in the near future.**

### Inputs

#### Parameters

 - **collect-evidence**: (Default: `true`) Determines if the task should write to the evidence locker repo. Defaults to collecting evidence.
 - **pipeline-pvc**: The output pvc to check out and store task scripts & data between tasks
 - **repository**: The git repo of the application to be deployed
 - **ibmcloud-api-key**: IBM Cloud API key with access to the toolchain
 - **servicenow-api-token**: A valid ServiceNow API token
 - **servicenow-api-url**: The ServiceNow API URL you wish to use (test or live)
 - **servicenow-configuration-item**: The name of the service to be deployed as it is registered in ServiceNow
 - **cluster**: The name or ID of the target production cluster.
 - **cluster-region**: The target region of production cluster.
 - **cluster-namespace**: The namespace of target production cluster.
 - **application**: Application label of build image
 - **emergency-label**: Label used for your Emergency releases, issues and PRs on GitHub
 - **evidence-locker-url**: Evidence locker repo URL to store compliance related evidences
 - **pipeline-run-id**: ID of the current pipeline run
 - **image**: (Default: `noImage`) The image name and version to deploy
 - **change-request-id**: (Default: `notAvailable`) optional ServiceNow Change Request ID to use in deployment
 - **ibmcloud-api**: (Default: `https://cloud.ibm.com`) ibmcloud api endpoint
 - **gitUser**: (Default: `""`) User to clone with. Leave blank to pickup the details from the PVC `/artifacts/credentials/cred.json`
 - **gitToken**: (Default: `""`) Git Token to clone with. Leave blank to pickup the details from the PVC `/artifacts/credentials/cred.json`
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

### Outputs

Sets up scripts for communicating with ServiceNow API in the PVC `/artifacts/cocoa-scripts`

Saves Change Request ID as an entry in `/artifacts/build.properties`

## Usage

Example usage in a pipeline, running after the [`get-git-credentials`](/preview/git/#get-git-credentials) task, using the Git credentials from that task.

``` yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: cd-pipeline
spec:
  params:
    - name: pipeline-pvc
    - name: repository
    - name: ibmcloud-api-key
    - name: servicenow-api-token
    - name: servicenow-api-url
    - name: servicenow-configuration-item
    - name: cluster
    - name: cluster-region
    - name: cluster-namespace
    - name: application
    - name: emergency-label
    - name: evidence-locker-url
    - name: pipeline-run-id
    - name: image
      default: "noImage"
    - name: change-request-id
      default: "notAvailable"
  tasks:

    - name: get-git-credentials
      taskRef:
        name: get-git-credentials
      params:
        - name: credentials-pvc
          value: $(params.pipeline-pvc)
        - name: ibmcloud-api-key
          value: $(params.ibmcloud-api-key)
        - name: repository
          value: $(params.repository)

    - name: pipeline-create-cr
      taskRef:
        name: create-change-request
      runAfter:
        - get-git-credentials
      params:
        - name: pipeline-pvc
          value: $(params.pipeline-pvc)
        - name: repository
          value: $(params.repository)
        - name: ibmcloud-api-key
          value: $(params.ibmcloud-api-key)
        - name: servicenow-api-token
          value: $(params.servicenow-api-token)
        - name: servicenow-api-url
          value: $(params.servicenow-api-url)
        - name: servicenow-configuration-item
          value: $(params.servicenow-configuration-item)
        - name: cluster
          value: $(params.cluster)
        - name: cluster-region
          value: $(params.cluster-region)
        - name: cluster-namespace
          value: $(params.cluster-namespace)
        - name: application
          value: $(params.application)
        - name: emergency-label
          value: $(params.emergency-label)
        - name: evidence-locker-url
          value: $(params.evidence-locker-url)
        - name: pipeline-run-id
          value: $(params.pipeline-run-id)
        - name: image
          value: $(params.image)
        - name: change-request-id
          value: $(params.change-request-id)
```

For a full example see the pipeline for [the compliant-cd-pipeline template](https://github.ibm.com/one-pipeline/compliance-cd-toolchain)


## check-change-request-approval

Check the approval status of a Change Request in ServiceNow. This task relies on the output of the `create-change-request` task.

### Inputs

#### Parameters
 - **collect-evidence**: (Default: `true`) Determines if the task should write to the evidence locker repo. Defaults to collecting evidence.
 - **pipeline-pvc**: The output pvc to check out and store task scripts & data between tasks
 - **servicenow-api-token**: A valid ServiceNow API token
 - **servicenow-api-url**: The ServiceNow API URL you wish to use (test or live)
 - **evidence-locker-url**: Evidence locker repo URL to store compliance related evidences
 - **pipeline-run-id**: ID of the current pipeline run
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Dependencies

 - Change Request ID as an entry in `/artifacts/build.properties`


### Outputs

None, will stop pipeline run if the CR is not approved or not found.

## Usage

Example usage in a pipeline, running after the `create-change-request` task.

``` yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: cd-pipeline
spec:
  params:
    - name: pipeline-pvc
    - name: repository
    - name: ibmcloud-api-key
    - name: servicenow-api-token
    - name: servicenow-api-url
    - name: evidence-locker-url
    - name: pipeline-run-id
  tasks:

    - name: get-git-credentials
      taskRef:
        name: get-git-credentials
      params:
        - name: credentials-pvc
          value: $(params.pipeline-pvc)
        - name: ibmcloud-api-key
          value: $(params.ibmcloud-api-key)
        - name: repository
          value: $(params.repository)

    - name: pipeline-create-cr
      taskRef:
        name: create-change-request
      runAfter:
        - get-git-credentials
      params:
        # see the params of create-change-request above

    - name: pipeline-check-cr-approval
      taskRef:
        name: check-change-request-approval
      runAfter:
        - pipeline-create-cr
      params:
        - name: task-pvc
          value: $(params.pipeline-pvc)
        - name: evidence-locker-url
          value: $(params.evidence-locker-url)
        - name: pipeline-run-id
          value: $(params.pipeline-run-id)
        - name: servicenow-api-token
          value: $(params.servicenow-api-token)
        - name: servicenow-api-url
          value: $(params.servicenow-api-url)
```

For a full example see the pipeline for [the compliant-cd-pipeline template](https://github.ibm.com/one-pipeline/compliance-cd-toolchain)


## close-change-request

Close the Change Request in ServiceNow. This task relies on the output of the `create-change-request` task.

### Inputs

#### Parameters

 - **pipeline-pvc**: The output pvc to check out and store task scripts & data between tasks
 - **servicenow-api-token**: A valid ServiceNow API token
 - **servicenow-api-url**: The ServiceNow API URL you wish to use (test or live)
 - **evidence-locker-url**: Evidence locker repo URL to store compliance related evidences
 - **pipeline-run-id**: ID of the current pipeline run
 - **collect-evidence**: (Default: `true`) Determines if the task should write to the evidence locker repo. Defaults to collecting evidence.
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Dependencies

 - Change Request ID as an entry in `/artifacts/build.properties`


### Outputs

None, will stop pipeline run if the CR cannot be closed or not found.

## Usage

Example usage in a pipeline, running after the `create-change-request` task.

``` yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: cd-pipeline
spec:
  params:
    - name: pipeline-pvc
    - name: repository
    - name: ibmcloud-api-key
    - name: servicenow-api-token
    - name: servicenow-api-url
    - name: evidence-locker-url
    - name: pipeline-run-id

  tasks:

    - name: get-git-credentials
      taskRef:
        name: get-git-credentials
      params:
        - name: credentials-pvc
          value: $(params.pipeline-pvc)
        - name: ibmcloud-api-key
          value: $(params.ibmcloud-api-key)
        - name: repository
          value: $(params.repository)

    - name: pipeline-create-cr
      taskRef:
        name: create-change-request
      runAfter:
        - get-git-credentials
      params:
        # see the params of create-change-request above

    - name: pipeline-close-cr
      taskRef:
        name: close-change-request
      runAfter:
        - pipeline-create-cr
      params:
        - name: task-pvc
          value: $(params.pipeline-pvc)
        - name: evidence-locker-url
          value: $(params.evidence-locker-url)
        - name: pipeline-run-id
          value: $(params.pipeline-run-id)
        - name: servicenow-api-token
          value: $(params.servicenow-api-token)
        - name: servicenow-api-url
          value: $(params.servicenow-api-url)
```

For a full example see the pipeline for [the compliant-cd-pipeline template](https://github.ibm.com/one-pipeline/compliance-cd-toolchain)

