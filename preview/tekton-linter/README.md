# YAML
Tasks for lint the Tekton files.

#### Tasks
- [tekton-lint](#tekton-lint)

## tekton-lint
This task uses the [tekton-linter](https://github.ibm.com/cocoa/tekton-lint) written by the CoCoA team.
The linter is responsible to enforce conventios, like naming, parameter usage etc.


**WARNING: This task needs to run on Kubernetes cluster with minimal version 1.15. If you are using your own Delivery Pipeline Private Worker to run your tekton pipeline(s), ensure your cluster is updated to this version at least.**

If using Git Statues URL this task requires git credentials in JSON file mounted to `/secrets/credentials/cred.json`
See [get-git-credentials](/preview/git/README.md) task.


### Inputs

#### Parameters

- **task-pvc**: The volume where the files for linting are expected to be
- **path**: Path to YAML, List of YAMLs or directory containing YAMLS to scan. When using directories all
sub directories are scanned. By default is will scan all YAMLs in your repo
- **statuses-url** (*Optional* Default: `""`) Set the github statues url to enable git status updates
- **status-context** (*Optional* Default: `"Tekton Linter"`) When using github statues customise the status context
- **status-pending-description** (*Optional* Default: `"Running Tekton Linter..."`) When using github statues customise the status pending description
- **status-success-description** (*Optional* Default: `"Tekton Linter Passed"`) When using github statues customise the status success description
- **status-fail-description** (*Optional* Default: `"Tekton Lint Failed"`) When using github statues customise the status failed description
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

## Usage

The task is **highly** dependent on the `GITHUB_TOKEN` environment variable, since it is not a parameter, please run the [get-git-credentials](/preview/git/README.md)


Get git credentials with [get-git-credentials](/preview/git/README.md)
Run task and update git status. Clone using [clone-repo-task](https://github.com/open-toolchain/tekton-catalog/tree/master/git).


``` yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: pr-pipeline
spec:
  params:
    - name: statuses-url
      description: the status url to update
    - name: pipeline-pvc
      description: the pipeline pvc name
    - name: ibmcloud-api-key
      description: ibm cloud api key
    - name: repository
      description: the git repo
    - name: branch
      description: the branch for the git repo
    - name: pipeline-run
      description: The unique pipelineRunId
    - name: revision
      description: |
        the git revision/commit to update the git HEAD to.
        Default is to mean only use the branch
  tasks:
    - name: get-git-credentials
      taskRef:
        name: get-git-credentials
      runAfter:
        - clone
      params:
        - name: credentials-pvc
          value: $(params.pipeline-pvc)
        - name: ibmcloud-api-key
          value: $(params.ibmcloud-api-key)
        - name: repository
          value: $(params.repository)
    - name: clone
      taskRef:
        name: clone-repo-task
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
    - name: tekton-linting
      taskRef:
        name: tekton-lint
      runAfter:
        - clone
      params:
        - name: statuses-url
          value: $(params.statuses-url)
        - name: task-pvc
          value: $(params.pipeline-pvc)
        - name: task-pvc
          value: $(params.pipeline-pvc)
        - name: pipeline-run
          value: $(params.pipeline-run)
```
