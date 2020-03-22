#!/bin/sh

# Building an image from the above Dockerfile will compile the kernel module
docker build -t ybhutdocker/falco-docker-desktop .
#If you’re using a newer version of Docker Desktop, or want to use a specific version of Falco, you can use the same Dockerfile and pass in build arguments
# docker build --build-arg KERNEL_VERSION=4.14.131 -t falco-docker-desktop .

# Running the resulting image will install the kernel module
docker run -it --rm --privileged ybhutdocker/falco-docker-desktop

# Running Falco
# docker run -e "SYSDIG_SKIP_LOAD=1" -it --rm --name falco --privileged -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro falcosecurity/falco:0.18.0

#TODO: run in kind
