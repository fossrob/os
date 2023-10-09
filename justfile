image:="os"
flavor:="main"

all image:
  just registry
  just build {{image}}
  just push {{image}}
  just update

registry:
    #!/bin/bash
    set -euo pipefail
    podman container inspect registry >/dev/null 2>&1 || podman run --rm --detach --pull always --publish 5000:5000 --volume ~/docker-registry:/var/lib/registry --name registry registry:latest

layer-image container_file:
  #!/bin/bash
  set -euo pipefail

  just registry

  container_tag=$(echo "{{container_file}}" | sed -re 's/^Containerfile\.//')

  podman build --no-cache --tag fedora-test:${container_tag} --file {{container_file}}
  podman push fedora-test:${container_tag} localhost:5000/fedora-test:${container_tag}

build image="dx":
  buildah build --format docker --tls-verify=true --build-arg SOURCE_IMAGE=quay.io/fedora-ostree-desktops/silverblue:38 \
    --layers --cache-from localhost:5000/{{image}} --tag {{image}} --file Containerfile.{{image}} --log-level error

push image="dx":
  podman push {{image}}:latest localhost:5000/{{image}}:latest

rebase image:
  rpm-ostree rebase ostree-unverified-image:docker://localhost:5000/{{image}}

run image *FLAGS:
  podman run --rm --interactive --tty localhost:5000/{{image}} {{FLAGS}}

update:
  rpm-ostree update

clean image:
  podman push localhost/{{image}}:latest localhost:5000/{{image}}:latest
