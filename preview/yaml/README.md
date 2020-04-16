# YAML
Tasks for working with YAML files.

#### Tasks
- [lint](#lint)

## lint
This task uses the Python `yamllint` package to lint YAML files. `yamllint` not only checks for syntax validity,
 but for weirdness's like key repetition and cosmetic problems such as lines length, trailing spaces, indentation, etc.
 A rules configuration can be provided if you want to customise the linter.

https://yamllint.readthedocs.io/en/stable/

**WARNING: This task needs to run on Kubernetes cluster with minimal version 1.15. If you are using your own Delivery Pipeline Private Worker to run your tekton pipeline(s), ensure your cluster is updated to this version at least.**

If using Git Statues URL this task requires git credentials in JSON file mounted to `/secrets/credentials/cred.json`
See [get-git-credentials](/preview/git/README.md) task.


### Inputs

#### Parameters

- **task-pvc**: The volume where the files for linting are expected to be
- **path**: Path to YAML, List of YAMLs or directory containing YAMLS to scan. When using directories all
sub directories are scanned. By default is will scan all YAMLs in your repo
- **rules**: Custom rules file to apply to the linter. If you provide the value "relaxed" it will use the default
 relaxed rule set. This is not needed if a rules config file with the name `.yamllint`, `.yamllint.yaml` or
 `.yamllint.yml` in the root of your repo. [See official documentation for how to configure the rules file](https://yamllint.readthedocs.io/en/stable/configuration.html)
- **strict-mode** (*Optional* Default: `"true"`) Set `--strict` mode
- **flags** Add additional flags that `yamllint` can accept here.
- **fail_task** (*Optional* Default: `"false"`) Set `true` or `false`, Fail task on linting failure when `true`
- **statuses_url** (*Optional* Default: `""`) Set the github statues url to enable git status updates
- **statuses__target_url** (*Optional* Default: `"https://cloud.ibm.com/devops/"`) Set the github statues target url
- **status_context** (*Optional* Default: `"Tekton YAML Lint"`) When using github statues customise the status context
- **status_pending_description** (*Optional* Default: `"Tekton running YAML Lint..."`) When using github statues customise the status pending description
- **status_success_description** (*Optional* Default: `"YAML Lint Passed"`) When using github statues customise the status success description
- **status_fail_description** (*Optional* Default: `"Tekton Failed YAML Lint..."`) When using github statues customise the status failed description
- **gitUser** (*Optional* Default: `""`) When using github statues, the user to update git status. Leave blank to pickup the details from the PVC `/secrets/credentials/cred.json`
- **gitPassword** (*Optional* Default: `""`) When using github statues, the password of user to update git status. Leave blank to pickup the details from the PVC `/secrets/credentials/cred.json`
- **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

See full YAMLLint documentation for more examples https://yamllint.readthedocs.io/en/stable/

## Usage

Run task without git status. Clone using [clone-repo-task](https://github.com/open-toolchain/tekton-catalog/tree/master/git)

``` yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: pr-pipeline
spec:
  params:
    - name: pipeline-pvc
      description: the pipeline pvc name
    - name: repository
      description: the git repo
    - name: branch
      description: the branch for the git repo
    - name: revision
      description: |
        the git revision/commit to update the git HEAD to.
        Default is to mean only use the branch
  tasks:
    - name: clone
      taskRef:
        name: clone-repo-task
      params:
        - name: task-pvc
          value: $(params.pipeline-pvc)
        - name: repository
          value: $(params.repository)
        - name: branch
          value: $(params.branch)
        - name: revision
          value: $(params.revision)
    - name: linting
      taskRef:
        name: yaml-lint
      runAfter:
        - clone
      params:
        - name: rules
          value: "yamllint-rules.yaml"
        - name: fail_task
          value: "true"
        - name: task-pvc
          value: $(params.pipeline-pvc)

```

Run task and update git status. Clone using [clone-repo-task](https://github.com/open-toolchain/tekton-catalog/tree/master/git).
Get git credentials with [get-git-credentials](/preview/git/README.md)


``` yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: pr-pipeline
spec:
  params:
    - name: statuses_url
      description: the status url to update
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
    - name: clone
      taskRef:
        name: clone-repo-task
      params:
        - name: task-pvc
          value: $(params.pipeline-pvc)
        - name: repository
          value: $(params.repository)
        - name: branch
          value: $(params.branch)
        - name: revision
          value: $(params.revision)
    - name: get-git-credentials
      taskRef:
        name: get-git-credentials
      runAfter:
        - clone
      params:
        - name: credentials-pvc
          value: $(params.pipeline-pvc)
        - name: ibmcloud-api-key
          value: $(params.ibm-cloud-api-key)
        - name: repository
          value: $(params.repository)
    - name: linting
      taskRef:
        name: yaml-lint
      runAfter:
        - get-git-credentials
      params:
        - name: rules
          value: "yamllint-rules.yaml"
        - name: fail_task
          value: "true"
        - name: statuses_url
          value: $(params.statuses_url)
        - name: task-pvc
          value: $(params.pipeline-pvc)
```
