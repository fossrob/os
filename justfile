image:="os"

build image=image:
  buildah build --format docker --tls-verify=true --tag {{image}} --target {{image}}
  just run {{image}} bash

run image *FLAGS:
  podman run --rm --interactive --tty localhost/{{image}} {{FLAGS}}
