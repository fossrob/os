distrobox-install:
  echo 'Installing distrobox for the current user...'
  curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
