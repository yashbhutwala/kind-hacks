ARG ALPINE_VERSION=3.10
ARG KERNEL_VERSION=4.9.184

FROM alpine:${ALPINE_VERSION} AS alpine

FROM linuxkit/kernel:${KERNEL_VERSION} AS kernel

FROM alpine
ARG FALCO_VERSION=0.17.0
ARG SYSDIG_VERSION=0.26.4

COPY --from=kernel /kernel-dev.tar /

RUN apk add --no-cache --update wget ca-certificates \
    build-base gcc abuild binutils \
    bc \
    cmake \
    git \
    autoconf && \
  export KERNEL_VERSION=`uname -r  | cut -d '-' -f 1`  && \
  export KERNEL_DIR=/usr/src/linux-headers-${KERNEL_VERSION}-linuxkit/ && \
  tar xf /kernel-dev.tar && \
  cd $KERNEL_DIR && \
  zcat /proc/1/root/proc/config.gz > .config && \
  make olddefconfig && \
  mkdir -p /falco/build && \
  mkdir /src && \
  cd /src && \
  wget https://github.com/falcosecurity/falco/archive/$FALCO_VERSION.tar.gz && \
  tar zxf $FALCO_VERSION.tar.gz && \
  wget https://github.com/draios/sysdig/archive/$SYSDIG_VERSION.tar.gz && \
  tar zxf $SYSDIG_VERSION.tar.gz && \
  mv sysdig-$SYSDIG_VERSION sysdig && \
  cd /falco/build && \
  cmake /src/falco-$FALCO_VERSION
# WORKDIR /falco/build
# RUN make driver && \
#   rm -rf /src && \
#   apk del wget ca-certificates \
#     build-base gcc abuild binutils \
#     bc \
#     cmake \
#     git \
#     autoconf

CMD ["insmod","/falco/build/driver/falco-probe.ko"]
