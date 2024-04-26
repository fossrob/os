# start a basic local docker registry
registry:
    podman container inspect registry >/dev/null 2>&1 || podman run --rm --detach --pull always --publish 5000:5000 --volume ~/docker-registry:/var/lib/registry --name registry registry:latest

# test local build of variant
build-image variant version:
    podman build --build-arg FEDORA_VERSION={{ version }} --tag fedora-{{ variant }}:{{ version }} --file Containerfile.{{ variant }}

# test local build of variant (no-cache)
build-image-no-cache variant version:
    podman build --no-cache --build-arg FEDORA_VERSION={{ version }} --tag fedora-{{ variant }}:{{ version }} --file Containerfile.{{ variant }}

# push to local registry
push-image variant version:
    just registry
    podman push fedora-{{variant}}:{{ version }} localhost:5000/fedora-{{variant}}:{{ version }}

rebase variant version:
    rpm-ostree rebase ostree-unverified-registry:localhost:5000/fedora-{{variant}}:{{ version }}

# list contents of container image
list-image container:
    podman image save {{container}} | tar --extract --to-stdout --exclude layer.tar '*.tar' | tar --list --verbose

# view added configs with fzf
config-added:
    sudo ostree admin config-diff | grep ^A | awk '{print $2}' | fzf --tac --bind "enter:execute(sudo less /etc/{})"

# compare modified configs with fzf
config-diff:
    sudo ostree admin config-diff | grep ^M | awk '{print $2}' | fzf --tac --bind "enter:execute(sudo vimdiff /usr/etc/{} /etc/{})"
