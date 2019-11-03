https://garethr.dev/2019/08/running-falco-on-docker-desktop/

docker build -t falco-docker-desktop .
docker run -it --rm --privileged falco-docker-desktop

docker build --build-arg KERNEL_VERSION=4.14.131 -t falco-docker-desktop .

docker run -e "SYSDIG_SKIP_LOAD=1" -it --rm --name falco --privileged -v /var/run/docker.sock:/host/var/run/docker