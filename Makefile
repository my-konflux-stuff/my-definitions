
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

task_name ?= example

.PHONY: task/new
task/new:
	mkdir -p task/$(task_name)/0.1/
	printf "# Task $(task_name)\n\nCreated by Makefile" >task/$(task_name)/README.md
	sed "s/\$task_name/$(task_name)/" task-templ.yaml >task/$(task_name)/0.1/$(task_name).yaml

old_version ?= 0.1
new_version ?= 0.2

.PHONY: task/bump-version
task/bump-version:
	mkdir -p task/$(task_name)/$(new_version)/
	cp task/$(task_name)/$(old_version)/$(task_name).yaml task/$(task_name)/$(new_version)/
	sed -iE 's|( +app\.kubernetes\.io/version:) "[0-9]+\.[0-9]+(\.[0-9]+)?"|\1 "$(new_version)"|' \
		task/$(task_name)/$(new_version)/$(task_name).yaml
	git add task/$(task_name)/$(new_version)/
