#!/usr/bin/env bash
snapshot=${1:?Missing snapshot name}
temp_release_cr=/tmp/release-cr.yaml
if ! [[ -f releases/release-templ.yaml ]]
then
    printf "The current working directory seems not correct. Cannot find releases/release-templ.yaml\n" >&2
    exit 1
fi
yq ".spec.snapshot |= \"${snapshot}\"" releases/release-templ.yaml >"$temp_release_cr"
printf "Apply Release:\n\n"
trap 'rm "$temp_release_cr"' EXIT ERR
cat "$temp_release_cr"
printf "\n"
kubectl create -f "$temp_release_cr" -n cqi-tenant
