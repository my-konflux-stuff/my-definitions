#!/usr/bin/env bash
snapshot=${1:?Missing snapshot name}
temp_release_cr=/tmp/release-cr.yaml
yq ".spec.snapshot |= \"${snapshot}\"" releases/release-templ.yaml >"$temp_release_cr"
printf "Apply Release:\n\n"
trap 'rm "$temp_release_cr"' EXIT ERR
cat "$temp_release_cr"
printf "\n"
kubectl create -f "$temp_release_cr" -n cqi-tenant
