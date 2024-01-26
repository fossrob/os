# start a basic local docker registry
registry:
    podman container inspect registry >/dev/null 2>&1 || podman run --rm --detach --pull always --publish 5000:5000 --volume ~/docker-registry:/var/lib/registry --name registry registry:latest

# test local build of variant
build-image variant:
    podman build --no-cache --build-arg FEDORA_VERSION=39 --tag fedora-{{variant}}:39 --file Containerfile.{{variant}}

# push to local registry
push-image variant:
    just registry
    podman push fedora-{{variant}}:39 localhost:5000/fedora-{{variant}}:39

# list contents of container image
list-image container:
    podman image save {{container}} | tar --extract --to-stdout --exclude layer.tar '*.tar' | tar --list --verbose

# view added configs with fzf
config-added:
    sudo ostree admin config-diff | grep ^A | awk '{print $2}' | fzf --tac --bind "enter:execute(sudo less /etc/{})"

# compare modified configs with fzf
config-diff:
    sudo ostree admin config-diff | grep ^M | awk '{print $2}' | fzf --tac --bind "enter:execute(sudo vimdiff /usr/etc/{} /etc/{})"
