
quay_namespace ?= mytestworkload/my-tekton-catalog
build_tag ?= $(shell git rev-parse HEAD)
skip_build ?= 1
skip_install ?= 1
output_task_bundle_list ?= task-bundle-list-konflux-ci
output_pipeline_bundle_list ?= task-pipeline-list-konflux-ci
build_tasks ?= "publish-artifacts "


.PHONY: build-and-push
build-and-push:
	QUAY_NAMESPACE=$(quay_namespace) \
	BUILD_TAG=$(build_tag) \
	SKIP_BUILD=$(skip_build) \
	SKIP_INSTALL=$(skip_install) \
	OUTPUT_TASK_BUNDLE_LIST=$(output_task_bundle_list) \
	OUTPUT_PIPELINE_BUNDLE_LIST=$(output_pipeline_bundle_list) \
	TEST_TASKS=$(build_tasks) \
	hack/build-and-push.sh
