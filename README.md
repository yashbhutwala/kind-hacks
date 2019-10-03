
# kind command to run to create a 3 node cluster: 1 master and 2 worker nodes
# settings enable auditing on the api-server as well as
# map host ports 80 and 443 with one of the workers for usage
# with an ingress deployed as a daemonset or nodeport

kind create cluster --config /Users/bhutwala/kind/kind-multi-node-cluster.yaml --name kind-multi-node-cluster

# all polaris images come from gcr, which can be pulled using the pull secret
# however, the postgres image comes from a redhat registry, so you have to load it
# into all the nodes manually
kind load docker-image registry.access.redhat.com/rhscl/postgresql-10-rhel7:1 --name=kind-multi-node-cluster


# edit yamls

edit postgres deployment's mountpath to /var/lib/postgresql/data
# https://raw.githubusercontent.com/blackducksoftware/releases/Development/polaris/2019.10.0.0.5186.0.0.757.0.0.1363/polarisdb_base.yaml

edit all pvc storage things to run 1G

make eventstore go from 3 -> 1
(in order to this, have to also edit the init job: https://github.com/blackducksoftware/releases/blob/Development/polaris/2019.10.0.0.5344.0.0.762.0.0.1384/polarisdb_base.yaml#L1267)
