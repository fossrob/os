distrobox-install:
  echo 'Installing distrobox for the current user...'
  curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local

distrobox-f38:
  echo 'Creating F38 distrobox for the current user...'
  distrobox create --image registry.fedoraproject.org/fedora-toolbox:38 --name f38 -Y
