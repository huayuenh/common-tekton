# inventory
Tasks for working with the inventory

#### Tasks
- [merge-cr-inventory-branch](#merge-cr-inventory-branch)
- [update-inventory](#update-inventory)

## merge-cr-inventory-branch
Merges inventory changes from the change request branch into master

### Inputs

#### Parameters
 - **task-pvc**: The output pvc - this is where the cloned repository will be store
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode

## Usage
Pipeline with task-pvc

```
- name: pipeline-merge-cr-inventory-branch
  taskRef:
    name: merge-cr-inventory-branch
  runAfter:
    - pipeline-deployment
  params:
    - name: task-pvc
      value: $(params.pipeline-pvc)
```

## update-inventory
Creates a cr branch into the inventory repository with the proposed changes

### Inputs

#### Parameters
 - **task-pvc**: The output pvc - this is where the cloned repository will be stored
 - **pipeline-debug**: (Default: `"0"`) enable pipeline debug mode
 - **properties-file**: (Default: `build.properties`) file containing properties out of containerize task
 - **version**: (Default: `""`) the version of the application to be deployed
 - **inventory-integration**: (Default: `inventory-repo`) the name of the inventory repo integration
 - **inventory-repo**: (Default: `""`) the inventory repository, in owner and repo name format

## Usage
Pipeline with task-pvc

```
- name: update-inventory-task
  taskRef:
    name: update-inventory-task
  runAfter:
    - containerize-task
  params:
    - name: task-pvc
      value: $(params.credentials-pvc)
    - name: pipeline-debug
      value: $(params.pipeline-debug)
    - name: inventory-repo
      value: $(params.inventory-repo)
    - name: version
      value: $(params.version)
```
