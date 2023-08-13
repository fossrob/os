image:="os"

registry:
  podman run -d -p 5000:5000 --restart=always --name registry registry:2

build image=image flavor="main":
  buildah build --format docker --tls-verify=true --tag {{image}} --target {{image}} --build-arg IMAGE_FLAVOR={{flavor}} --layers --cache-from localhost:5000/os
  just push {{image}}
  just run {{image}} bash

push image:
  podman push localhost/{{image}}:latest localhost:5000/{{image}}:latest

run image *FLAGS:
  podman run --rm --interactive --tty localhost/{{image}} {{FLAGS}}
