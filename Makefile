
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

task_version ?= 0.1

.PHONY: task/create-migration/in-version
task/create-migration/in-version:
	set -e; \
	task_file=task/$(task_name)/$(task_version)/$(task_name).yaml; \
	IFS=. read -r major minor patch_ < <(yq '.metadata.labels."app.kubernetes.io/version"' "$$task_file"); \
	old_version="$${major}.$${minor}.$${patch_}"; \
	((patch_++)); \
	new_version="$${major}.$${minor}.$${patch_}"; \
	line_no=$$(yq '.metadata.labels."app.kubernetes.io/version" | line' "$$task_file"); \
	sed -i "$${line_no}s/$${old_version}/$${new_version}/" "$$task_file"; \
	mkdir task/$(task_name)/$(task_version)/migrations || : ;\
	migration_file="task/$(task_name)/$(task_version)/migrations/$${new_version}".sh; \
	printf "#!/usr/bin/env bash\n\nprintf \"migration for version $${new_version}\"" >"$$migration_file"; \
	git add "$$task_file" "$$migration_file"

.PHONY: task/bump-version
task/bump-version:
	set -ex; \
	IFS=. read -r major minor < <(find task/$(task_name) -mindepth 1 -maxdepth 1 -type d -exec basename '{}' \; | sort -t. -k 1,1n -k 2,2n | tail -n 1); \
	old_version="$${major}.$${minor}"; \
	((minor++)); \
	new_version="$${major}.$${minor}"; \
	task_dir=task/$(task_name)/$${new_version}; \
	if [[ -e "$$task_dir" ]]; then printf "Task directory exists already: %s" "$$task_dir"; exit 1; fi; \
	mkdir "$$task_dir"; \
	new_task_file="$${task_dir}/$(task_name).yaml"; \
	cp "task/$(task_name)/$${old_version}/$(task_name).yaml" "$$new_task_file"; \
	line_no=$$(yq '.metadata.labels."app.kubernetes.io/version" | line' "$$new_task_file"); \
	sed -i "$${line_no}s/$${old_version}/$${new_version}/" "$$new_task_file"; \
	git add "$$task_dir"
