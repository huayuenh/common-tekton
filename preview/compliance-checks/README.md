# compliance-checks
Tasks for covering compliance controls

#### Tasks

- [additional-image-checks](#additional-image-checks)
- [check-github-statuses](#check-github-statuses)
- [cis-benchmarks](#cis-benchmarks)
- [oss-licence-check](#oss-licence-check)
- [task-vulnerability-advisor](#task-vulnerability-advisor)
- [unit-tests](#unit-tests)

## additional-image-checks
Runs additional image checks.

This task is a placeholder, implementation is TBD.

## check-github-statuses
Checks if the required github setting are set up, and required status checks have run and passed.

### Inputs

#### Parameters

 - **collect-evidence**: (Default: `true`) Determines if the task should write to the evidence locker repo. Defaults to collecting evidence.
 - **pipelineRunId**: the unique id of the pipelinerun
 - **target-branch**: target branch where the required statuses and settings are checks
 - **task-pvc**: the output pvc - this is where the cloned repository will be stored
 - **requiredChecks**: array of required checks to verify in github
 - **context**: the context of the github checks (e.g. `tekton/pr-compliance`)
 - **repository-integration**: (Default: `" "`) the repository integration name, task will look for repo url under this name in `toolchain.json`
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

## Usage

Example usage in a pipeline.

``` yaml
    - name: check-github-statuses
      runAfter: [unit-tests]
      taskRef:
        name: check-github-statuses-task
      params:
      - name: task-pvc
        value: $(params.pipeline-pvc)
      - name: pipelineRunId
        value: $(params.pipelineRunId)
      - name: target-branch
        value: $(params.branch)
      - name: requiredChecks
        value: |
         [{
           "type": "status",
           "name": "unit-test",
           "params": {
             "name": "tekton/ci-unit-tests"
           }
         }]
      - name: context
        value: tekton/ci-compliance
```

## cis-benchmarks
Runs CIS benchmarks.

This task is a placeholder, implementation is TBD.

### Inputs

#### Parameters
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

## oss-licence-checks
Runs Open Source licence checks.

### Inputs

#### Parameters
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

This task is a placeholder, implementation is TBD.

## task-vulnerability-advisor
Runs Vulnerability Advisor scan of the provided docker image.

### Inputs

#### Parameters

  - **task-pvc**: the task pvc - this is the volume where the files (Dockerfile etc..) are expected to be
  - **ibmcloud-api-key**: The IBM Cloud API key
  - **ibmcloudApi**: (Default: `https://cloud.ibm.com`) the ibmcloud api
  - **continuous-delivery-context-secret**: (Default: `cd-secret`) name of the configmap containing the continuous delivery pipeline context secrets
  - **resourceGroup**: (Default: `' '`) target resource group (name or id) for the ibmcloud login operation
  - **imagePropertiesFile**: (Default: `build.properties`) file containing properties of the image to be scanned
  - **maxIteration**: (Default: `30`) maximum number of iterations allowed while loop to check for va report
  - **sleepTime**: (Default: `10`) sleep time (in seconds) between invocation of ibmcloud cr va in the loop
  - **scanReportFile**: (Default: `' '`) filename for the scan report (json format) of the given image. It will be copied in the task-pvc
  - **failOnScannedIssues**: (Default: `true`) flag (`true` | `false`) to indicate if the task should fail or continue if issues are found in the image scan result
  - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

#### Resources

  - **image**: the docker image built in another task

## Usage

Example usage in a pipeline.

``` yaml
- name: vulnerability-advisor
  taskRef:
    name: vulnerability-advisor-task
  params:
    - name: task-pvc
      value: $(params.pipeline-pvc)
    - name: ibmcloud-api-key
      value: $(params.ibmcloud-api-key)
    - name: scanReportFile
      value: 'app-image-va-report.json'
    - name: maxIteration
      value: '5'
    - name: sleepTime
      value: '3'
    - name: failOnScannedIssues
      value: 'false'
  resources:
    inputs:
      - name: image
        resource: app-image
        from:
          - containerize
```

## unit-tests
Looks for a cloned repository on the pvc and runs the unit tests on it. Reports the testrun status back to github.

### Inputs

####Parameters

 - **pipelineRunId**: the unique id of the pipelinerun
 - **task-pvc**: the output pvc - this is where the cloned repository will be stored
 - **context**: the context of the unit tests (e.g. `tekton/ci-unit-tests`)
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

## Usage

Example usage in a pipeline.

``` yaml
- name: unit-tests
  runAfter: [fetch-code]
  taskRef:
    name: unit-tests-task
  params:
  - name: task-pvc
    value: $(params.pipeline-pvc)
  - name: pipelineRunId
    value: $(params.pipelineRunId)
  - name: context
    value: tekton/ci-unit-tests
```
