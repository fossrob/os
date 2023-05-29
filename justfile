image := "os"

build *FLAGS:
  buildah build --format docker --tag {{ image }} --target {{ image }} {{FLAGS}}
  just run bash

run *FLAGS:
  podman run --rm --interactive --tty localhost/{{ image }} {{ FLAGS }}
