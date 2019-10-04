#!/bin/sh

export KIND_LOCATION="~/kind-hacks"
export KUBE_CONFIG_LOCATION="~/.kube"
export KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME}"

# create the kind cluster
kind create cluster --config ${KIND_LOCATION}/${KIND_CLUSTER_NAME}.yml --name ${KIND_CLUSTER_NAME}

# change kubeconfig to the kind config
cp ${KUBE_CONFIG_LOCATION}/kind-config-${KIND_CLUSTER_NAME} ${KUBE_CONFIG_LOCATION}/config

# deploy nginx ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml

# expose the nodeport to localhost:443
# https://banzaicloud.com/blog/kind-ingress/
for port in 80 443
do
    node_port=$(kubectl get service -n ingress-nginx ingress-nginx -o=jsonpath="{.spec.ports[?(@.port == ${port})].nodePort}")

    docker run -d --name ${KIND_CLUSTER_NAME}-kind-proxy-${port} \
      --publish 127.0.0.1:${port}:${port} \
      --link ${KIND_CLUSTER_NAME}-control-plane:target \
      alpine/socat -dd \
      tcp-listen:${port},fork,reuseaddr tcp-connect:target:${node_port}
done

# start ngrok
ngrok http https://localhost &


# all polaris images come from gcr, which can be pulled using the pull secret
# however, the postgres image comes from a redhat registry, so you have to load it
# into all the nodes manually

# kind load docker-image registry.access.redhat.com/rhscl/postgresql-10-rhel7:1 --name=${KIND_CLUSTER_NAME}
