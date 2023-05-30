image := "os"

build *FLAGS:
  buildah build --format docker --tls-verify=true --tag {{ image }} --target {{ image }} {{FLAGS}}
  just run bash

run *FLAGS:
  podman run --rm --interactive --tty localhost/{{ image }} {{ FLAGS }}
