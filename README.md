
# kind command to run to create a 3 node cluster: 1 master and 2 worker nodes
# settings enable auditing on the api-server as well as
# map host ports 80 and 443 with one of the workers for usage
# with an ingress deployed as a daemonset or nodeport

## Different versions of Kind
# https://godoc.org/sigs.k8s.io/kind/pkg/apis/config/v1alpha3#SetDefaults_Node
# https://hub.docker.com/r/kindest/node/tags?page=1&name=v1.11
# https://kind.sigs.k8s.io/docs/user/quick-start/#configuring-your-kind-cluster

# v1.11 latest
kind create cluster --image=kindest/node:v1.11.10 --name kind-v1.11.10

# v1.12 latest
kind create cluster --image=kindest/node:v1.12.10 --name kind-v1.12.10

# v1.13 latest
kind create cluster --image=kindest/node:v1.13.10 --name kind-v1.13.10

# v1.14 latest
kind create cluster --image=kindest/node:v1.14.6 --name kind-v1.14.6

# v1.15 latest
kind create cluster --image=kindest/node:v1.15.3 --name kind-v1.15.3
