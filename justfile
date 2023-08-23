image:="os"
flavor:="main"

registry:
  podman run --rm -d -p 5000:5000 --name registry registry:2

build image:
  buildah build --format docker --tls-verify=true --tag  --build-arg SOURCE_IMAGE=quay.io/fedora-ostree-desktops/silverblue:38 \
    --layers --cache-from localhost:5000/{{image}} --file Containerfile.{{image}}
  just push fresh

push image:
  podman push localhost/{{image}}:latest localhost:5000/{{image}}:latest

run image *FLAGS:
  podman run --rm --interactive --tty localhost/{{image}} {{FLAGS}}
