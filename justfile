# start a basic local docker registry
registry:
    podman container inspect registry >/dev/null 2>&1 || podman run --rm --detach --pull always --publish 5000:5000 --volume ~/docker-registry:/var/lib/registry --name registry registry:latest

# test local build of variant
build-image variant:
    podman build --no-cache --build-arg FEDORA_VERSION=39 --build-arg VARIANT={{variant}} --tag fedora-{{variant}}:39 --file Containerfile.{{variant}}

# list contents of container image
list-image container:
    podman image save {{container}} | tar --extract --to-stdout --exclude layer.tar '*.tar' | tar --list --verbose
