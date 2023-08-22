image:="os"

registry:
  podman run --rm -d -p 5000:5000 --name registry registry:2

build image=image flavor="main":
  buildah build --format docker --tls-verify=true --tag {{image}} --build-arg SOURCE_IMAGE=ghcr.io/ublue-os/silverblue-nvidia:38 --layers --cache-from localhost:5000/{{image}} --file Containerfile.{{image}}
  just push {{image}}
  just run {{image}} bash

push image:
  podman push localhost/{{image}}:latest localhost:5000/{{image}}:latest

run image *FLAGS:
  podman run --rm --interactive --tty localhost/{{image}} {{FLAGS}}
