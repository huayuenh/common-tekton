# git
Tasks for working with git

#### Tasks
- [get-git-credentials](#get-git-credentials)
- [git-clone](#git-clone)
- [clone-inventory-repo](#clone-incentory-repo)

## get-git-credentials
Retrieves git credential from toolchain and stores it as a json file in a mounted
volume. This can be used in later stages.

### Inputs

#### Parameters

  - **repository-integration**: (Default: `" "`) the repository integration name, task will look for repo url under this name in `toolchain.json`
  - **credentials-pvc**: The output PVC to store credentials
  - **repository**: The git repo url you wish to retrieve the credentials for
  - **ibmcloud-api-key**: IBM Cloud API key with access to the toolchain
  - **ibmcloud-api**: (Default: `https://cloud.ibm.com`) ibmcloud api endpoint
  - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

### Outputs
Appends the following values to the build properties file on the output PVC, default is `/artifacts/build.properties`
```bash
REPOSITORY
GIT_AUTH_USER
GIT_TOKEN
GHE_TOKEN
REPO_NAME
REPO
```

## Usage

Example usage in a pipeline, where YAMLLint uses the credentials
to update a git status

``` yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: credentials-pipeline
spec:
  params:
    - name: pipeline-pvc
      description: the pipeline pvc name
    - name: ibmcloud-api-key
      description: ibm cloud api key
    - name: repository
      description: the git repo
    - name: statuses_url
      description: the status url to update
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
      - name: linting
        taskRef:
          name: yaml-lint
        runAfter:
          - get-git-credentials
        params:
          - name: statuses_url
            value: $(params.statuses_url)
          - name: task-pvc
            value: $(params.pipeline-pvc)
```

For a full example see the pipeline for [this repository](/.tekton)

## git-clone
Clones a git repo to the mounted PVC

**Note:** If running in a CI Pipeline you do not want to just clone the PR's repository.
You need to merge the content of the PR with the origin you are going to be merging into.
In tools like Jenkins and Travis CI this is handled for us. I have provided the option to
specify the origin which if set will preform the merge. You can get the origin value from
the Pull Request event with `$(events.pull_request.base.ref)` in your trigger binding.
For an example see the pipeline for [this repository](/.tekton)

### Inputs

#### Parameters

- **task-pvc**: The output pvc - this is where the cloned repository will be stored
- **repository**: The git repository url we are cloning
- **branch**: (Default: `"master"`) The git branch
- **origin**: (Default: `""`) The origin you wish to merge code with
- **revision**: (Default: `""`) The git revision/commit to clone empty to just use branch
- **directoryName**: (Default: `"."`) Name of the new directory to clone into (inside the PVC)
- **gitUser**: (Default: `""`) User to clone with. Leave blank to pickup the details from the PVC `/secrets/credentials/cred.json`
- **gitPassword**: (Default: `""`) Password to clone with. Leave blank to pickup the details from the PVC `/secrets/credentials/cred.json`
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

### Outputs
The repository should be cloned into the mounted PVC

## Usage
TaskRun pull master with GIT Credentials passed in
```yaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: git-clone-run
spec:
  taskRef:
    name: git-clone
  inputs:
    params:
      - name: task-pvc
        value: pipeline-run-pvc
      - name: repository
        value: https://github.ibm.com/one-pipeline/common-tekton-tasks
      - name: gitUser
        value: "MYUSER@email.com"
      - name: gitPassword
        value: "XXXXXXXXXX"
```

Pipeline pull revision from branch with [get-git-credentials](#get-git-credentials)
```yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: pr-pipeline
spec:
  params:
    - name: pipeline-pvc
      description: the pipeline pvc name
    - name: ibm-cloud-api-key
      description: ibm cloud api key
    - name: repository
      description: the git repo
    - name: branch
      description: the branch for the git repo
    - name: revision
      description: |
        the git revision/commit to update the git HEAD to.
        Default is to mean only use the branch
  tasks:
    - name: get-git-credentials
      taskRef:
        name: get-git-credentials
      params:
        - name: credentials-pvc
          value: $(params.pipeline-pvc)
        - name: ibmcloud-api-key
          value: $(params.ibm-cloud-api-key)
        - name: repository
          value: $(params.repository)
    - name: clone
      taskRef:
        name: git-clone
      runAfter:
        - get-git-credentials
      params:
        - name: task-pvc
          value: $(params.pipeline-pvc)
        - name: repository
          value: $(params.repository)
        - name: branch
          value: $(params.branch)
        - name: revision
          value: $(params.revision)
```
For a full example see the pipeline for [this repository](/.tekton)

## clone-inventory-repo
Clones the given inventory repo and return the full image url from it

### Inputs

#### Parameters
  - **task-pvc**: The output pvc - this is where the cloned repository will be store
  - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

### Outputs
The IMAGE will be concatenated into the end of /artifacts/build.properties

## Usage

Pipeline with task-pvc [clone-inventory-repo](#clone-inventory-repo)

```yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: pr-pipeline
spec:
  params:
    - name: pipeline-pvc
      description: the pipeline pvc name
  tasks:
    - name: pipeline-clone-inventory-repo
      taskRef:
        name: clone-inventory-repo
      runAfter:
        - pipeline-clone-repo
      params:
        - name: task-pvc
          value: $(params.pipeline-pvc)
```
For a full example see the pipeline for [this repository](/.tekton)
