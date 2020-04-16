# Containerize

Tasks for containerizing the application.

#### Tasks
- [Containerize task](#containerize-task)

## Containerize task
This task pushes a new tagged docker image to the container registry based on the current content of the cluster and the container registry.

### Inputs
<List and describe the inputs for your task>

#### Parameters

- **task-pvc**: This is the volume where the files (Dockerfile etc..) are expected to be
- **ibm-cloud-api**: The IBM Cloud API
(<em>default: https://cloud.ibm.com</em>)
- **continuous-delivery-context-secret**: Name of the configmap containing the continuous delivery pipeline context secrets
(<em>default: cd-secret</em>)
- **resource-group**: Target resource group (name or id) for the ibmcloud login operation
(<em>default: '' </em>)
- **path-to-context**: The path to dockerbuild context
(<em>default: . </em>)
- **path-to-dockerfile**: The path to the dockerfile
(<em>default: . </em>)
- **dockerfile**: The name of the dockerfile
(<em>default: Dockerfile</em>)
- **buildkit-image**: The name of the BuildKit image
(<em>default: moby/buildkit:v0.6.3-rootless</em>)
- **additional-tags**: Comma-separated list of additionalTags
(<em>default: '' </em>)
- **additional-tags-script**: Shell script that allows to add tags for the image to be build.
(<em>default: '' </em>)
- **properties-file**: File containing properties out of containerize task
(<em>default: '' </em>)
 - **pipeline-debug**: enable pipeline debug mode
(<em>default: `"0"`</em>)

### Outputs

<List and describe outputs>

- **built-image**: The built docker image

## Usage

Example usage of containerize task where a docker image is built and pushed into registry with additional tags.

``` yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: example-pipeline
spec:
  params:
    - name: task-pvc
      description: This is the volume where the files (Dockerfile etc..) are expected to be
    - name: additional-tags-script
      description: Shell script that allows to add tags for the image to be build.
  tasks:
    name: containerize
      taskRef:
        name: containerize-task
      params:
      - name: task-pvc
        value: $(params.pipeline-pvc)
      - name: additional-tags-script
        value: |
          # Include the clone task output variables in the environment
          source /artifacts/build.properties
          # The script is providing tag(s) as output
          # But logs can be written as error stderr
          echo "Providing an image tag including git branch and commit" >&2
          # Add a specific tag with branch and commit
          echo "${BUILD_TIMESTAMP}-${GIT_BRANCH}-${GIT_COMMIT}"
      resources:
        outputs:
          - name: built-image
            resource: app-image
```
