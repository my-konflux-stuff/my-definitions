# my-definitions

## Onboard

- Onboard tasks via Web UI or gitops.
- The gitops way is preferred. Apply `./onboard.yaml`

## Release

- Create image repositories:
  - `quay.io/mytestworkload/my-tekton-catalog/task-init`
  - `quay.io/mytestworkload/my-tekton-catalog/task-tox`
  - `quay.io/mytestworkload/my-tekton-catalog/data-acceptance-tasks`
  - `quay.io/mytestworkload/my-definitions/release-trusted-artifacts`
- Create robot account with `write` permission on above image repositories.
- Create ServiceAccount for releasing images.
- Create Secrets in your tenant namespace and link it to the ServiceAccount.
- Apply EC policy `./releases/tekton-bundle-standard.yaml`
- If tekton bundle is built by a pipeline referencing tkn-bundle task via git-resolver,
  add these rules to `exclude`:
  ```yaml
          - slsa_build_scripted_build.image_built_by_trusted_task
          - tasks.pinned_task_refs:tkn-bundle-oci-ta
          - trusted_task.trusted:tkn-bundle-oci-ta
  ```
- Apply release configuration
  - `./releases/release-plan.yaml`
  - `./releases/rpa.yaml`
