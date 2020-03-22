#!/bin/bash

# https://news.ycombinator.com/item?id=10736584
set -o errexit -o nounset -o pipefail
# this line enables debugging
# set -xv

# hacked from: https://banzaicloud.com/blog/kind-ingress/

# input parameters
KIND_CLUSTER_NAME="${1:-"kind"}"
NAMESPACE="${2:-"default"}"
SERVICE_NAME="${3:-"frontend-external"}"

# expose the nodeport to https://localhost:443 and http://localhost:80
for port in 80 443
do
  node_port=$(kubectl get service -n "${NAMESPACE}" "${SERVICE_NAME}" -o=jsonpath="{.spec.ports[?(@.port == ${port})].nodePort}")
  docker run -d --name "${KIND_CLUSTER_NAME}-kind-proxy-${port}" \
    --publish "127.0.0.1:${port}:${port}" \
    --link "${KIND_CLUSTER_NAME}-control-plane:target" \
    "alpine/socat:1.7.3.4-r0" \
    "-dd tcp-listen:${port},fork,reuseaddr tcp-connect:target:${node_port}"
done
