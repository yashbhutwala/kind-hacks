#!/bin/bash

# https://news.ycombinator.com/item?id=10736584
set -o errexit -o nounset -o pipefail
# this line enables debugging
#set -xv

# USAGE:
#
# KIND_CLUSTER_NAME="kind";
# KIND_NODE_IMAGE="kindest/node:v1.14.10";
# ./kind-with-ingress.sh $KIND_CLUSTER_NAME $KIND_NODE_IMAGE

# REQUIREMENTS:
# 1. kind
# 2. kubectl

# LATEST TIME:
# ./kind-up-with-registry-and-ingress.sh  7.96s user 4.77s system 7% cpu 2:56.69 total

# parameters
KIND_CLUSTER_NAME="${1:-"kind"}"
KIND_NODE_IMAGE="${2:-"kindest/node:v1.14.10"}"

# create registry container unless it already exists
reg_name="kind-registry"
reg_port="5000"
running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  echo "creating a local docker registry"
  docker run \
    -d --restart=always -p "${reg_port}:5000" --name "${reg_name}" \
    "docker.io/registry:2"
fi
reg_ip="$(docker inspect -f '{{.NetworkSettings.IPAddress}}' "${reg_name}")"
printf "local registry hosted on port 'http://localhost:%s' as container named '%s' \n\n" ${reg_port} ${reg_name}

# create a ingress-ready cluster
running_clusters="$(docker inspect -f '{{.State.Running}}' "${KIND_CLUSTER_NAME}-control-plane" 2>/dev/null || true)"
#TODO: use kind-cli command instead of the above docker inspect
#running_clusters="$(kind get clusters 2>/dev/null | grep -cw "$KIND_CLUSTER_NAME")"
if [ "${running_clusters}" != 'true' ]; then
  cat <<EOF | kind -v 3 create cluster --name "${KIND_CLUSTER_NAME}" --image="${KIND_NODE_IMAGE}" --config=-
# 1 control-plane, 3 workers
# control-plane node ingress-ready and with ports 80,443 exposed
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
# point to the local registry
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_ip}:${reg_port}"]
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
        authorization-mode: "AlwaysAllow"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
- role: worker
EOF
  printf "waiting for all nodes to be 'Ready' ... \n\n"
  kubectl wait --for=condition="Ready" nodes --all --timeout="5m"
  printf "all nodes are ready \n\n"
  kubectl get nodes -owide
  # install ingress-nginx controller
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml;
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/provider/baremetal/service-nodeport.yaml;
  kubectl patch deployments -n ingress-nginx nginx-ingress-controller -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx-ingress-controller","ports":[{"containerPort":80,"hostPort":80},{"containerPort":443,"hostPort":443}]}],"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'
  printf "waiting for nginx-ingress-controller to be 'Available' ... \n\n"
  kubectl wait --for=condition="Available" -n ingress-nginx deployment/nginx-ingress-controller --timeout="5m"
  printf "nginx-ingress-controller is 'Available' \n\n"
  printf "cluster is ready!!! \n\n"
else
  printf "cluster with name '%s' already exists \n" "$KIND_CLUSTER_NAME \n\n"
fi

# start ngrok
# ngrok http https://localhost &
