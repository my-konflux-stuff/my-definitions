#!/usr/bin/env bash
snapshot=$1
yq ".spec.snapshot |= \"${snapshot}\"" releases/init-release.yaml >/tmp/init-release.yaml
printf "Apply Release:\n\n"
trap 'rm /tmp/init-release.yaml' EXIT ERR
cat /tmp/init-release.yaml
kubectl create -f /tmp/init-release.yaml -n cqi-tenant
