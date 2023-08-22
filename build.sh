#!/bin/sh

set -ouex pipefail

INCLUDED_PACKAGES=(
  bat fd-find fzf ripgrep the_silver_searcher
  hplip hplip-gui
  input-remapper
  kitty
  lm_sensors nvtop powertop tlp tlp-rdw
  bitstreamverasansmono-nerd-fonts cascadiacode-nerd-fonts dejavusansmono-nerd-fonts droidsansmono-nerd-fonts
  firacode-nerd-fonts firamono-nerd-fonts hack-nerd-fonts ibmplexmono-nerd-fonts inconsolata-nerd-fonts
  jetbrainsmono-nerd-fonts liberationmono-nerd-fonts meslo-nerd-fonts nerdfontssymbolsonly-nerd-fonts noto-nerd-fonts
  robotomono-nerd-fonts sourcecodepro-nerd-fonts ubuntumono-nerd-fonts
  podman-compose podmansh
  python3-pip
  starship
  subscription-manager
  tailscale
  zsh
)

EXCLUDED_PACKAGES=(
  distrobox
  fedora-repos-modular
  firefox firefox-langpacks mozilla-openh264
  fzf htop
  gnome-classic-session
  gnome-initial-setup
  gnome-software gnome-software-rpm-ostree
  gnome-tour
  supergfxctl gnome-shell-extension-supergfxctl-gex dconf-editor
)

for repo in $(ls /etc/yum.repos.d/*.repo); do
  sed -i $repo -e 's/enabled=1/enabled=0/'
done

if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  EXCLUDED_PACKAGES=($(rpm -qa --queryformat='%{NAME} ' ${EXCLUDED_PACKAGES[@]}))
  rpm-ostree override remove ${EXCLUDED_PACKAGES[@]}
fi

if [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  rpm-ostree install --idempotent --enablerepo fedora,updates,updates-archive,tailscale-stable,terra ${INCLUDED_PACKAGES[@]}
fi
