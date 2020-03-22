# https://hub.docker.com/_/alpine
ARG ALPINE_VERSION="3.10"
# https://docs.docker.com/docker-for-mac/release-notes/
# docker info | grep -i "Kernel"
# docker version
# https://hub.docker.com/r/linuxkit/kernel/tags?page=1&name=4.19.76
ARG KERNEL_VERSION="4.19.76"
# https://hub.docker.com/r/falcosecurity/falco/tags?page=1&name=minimal
# https://github.com/helm/charts/blob/master/stable/falco/values.yaml#L6
# https://github.com/falcosecurity/falco/blob/0.21.0/docker/minimal/Dockerfile
# https://github.com/falcosecurity/falco/blob/0.21.0/docker/kernel/linuxkit/Dockerfile
ARG FALCO_VERSION="0.21.0"

# linuxkit/kernel src
FROM linuxkit/kernel:${KERNEL_VERSION} AS ksrc

# falco
FROM falcosecurity/falco:${FALCO_VERSION}-minimal as falco

# probe-build
FROM alpine:${ALPINE_VERSION} AS probe-build
LABEL maintainer="cncf-falco-dev@lists.cncf.io"
ARG KERNEL_VERSION="4.19.76"
ENV KERNEL_VERSION=${KERNEL_VERSION}

COPY --from=ksrc /kernel-dev.tar /
COPY --from=falco /usr/src/ /usr/src/

RUN apk add --no-cache --update \
  build-base gcc abuild binutils \
  bc \
  autoconf && \
  export KERNELVER=`uname -r  | cut -d '-' -f 1`  && \
  export KERNELDIR=/usr/src/linux-headers-${KERNEL_VERSION}-linuxkit/ && \
  tar xf /kernel-dev.tar && \
  cd $KERNELDIR && \
  zcat /proc/1/root/proc/config.gz > .config && \
  make olddefconfig && \
  cd /usr/src/falco-* && \
  make && \
  apk del \
  build-base gcc abuild binutils \
  bc \
  autoconf

# final
FROM alpine:${ALPINE_VERSION}
COPY --from=probe-build /usr/src/falco-*/falco-probe.ko /
CMD ["insmod","/falco-probe.ko"]
