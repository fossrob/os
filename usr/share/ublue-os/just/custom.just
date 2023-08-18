distrobox-install:
  echo 'Installing distrobox for the current user...'
  curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local

distrobox-f38:
  echo 'Creating F38 distrobox for the current user...'
  distrobox create --image registry.fedoraproject.org/fedora-toolbox:38 --name f38 -Y

nix-devbox:
  echo 'Installing nix...'
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  echo 'Installing devbox...'
  curl -fsSL https://get.jetpack.io/devbox | bash
  echo 'You MUST reboot to continue'

# Install nix and Devbox (Global Profile)
nix-devbox-global:
  echo 'Installing devbox global profile...'
  devbox global pull https://devbox.getfleek.dev/high
  echo 'run "devbox global run install-hook-bash" to configure bash shell'
  echo 'run "devbox global run install-hook-zsh" to configure zsh shell'
  echo 'run "devbox global run" to see other available configuration commands'
