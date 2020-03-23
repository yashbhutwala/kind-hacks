# kind-hacks

## Useful scripts and yamls

* [run kind with registry and ingress enabled](./kind-up-with-registry-and-ingress.sh)
* [expose a nodeport of a service on your host machine](./expose-nodeport-locally.sh)
* [kind config to run with calico](./kind-calico.yaml)
* [kind config with audit logging enabled](./kind-audit-logging.yaml)

## Resources

* kind [k8s docker images](https://hub.docker.com/r/kindest/node/tags?page=1&name=v1.1), i.e.: kindest/node:v1.17.2
* kind [configuration](https://kind.sigs.k8s.io/docs/user/configuration/) docs
* kind [examples](https://github.com/kubernetes-sigs/kind/tree/4b3beebe8d2097b5c2be27de742e0ef15c78ec74/site/static/examples) code
* kind [godocs](https://pkg.go.dev/sigs.k8s.io/kind@v0.7.0/pkg/apis/config/v1alpha4?tab=doc)
* kind [CI](https://github.com/kind-ci/examples) examples
* kind [ingress](https://kind.sigs.k8s.io/docs/user/ingress/) examples
* kind [local registry](https://kind.sigs.k8s.io/docs/user/local-registry/) docs
* kind [enabling featureGates](https://kind.sigs.k8s.io/docs/user/quick-start/#enable-feature-gates-in-your-cluster) docs
* kind [exporting cluster logs](https://kind.sigs.k8s.io/docs/user/quick-start/#exporting-cluster-logs) docs
* [engineerd/setup-kind](https://github.com/engineerd/setup-kind) GitHub Action
* [helm/kind-action](https://github.com/helm/kind-action) GitHub Action
* [running](https://falco.org/docs/running/#running-falco-in-a-kind-cluster) and [installing](https://falco.org/docs/installation/#helm) Falco Security in Kind
