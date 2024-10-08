#!/usr/bin/env bash
set -ouex pipefail

INCLUDED_PACKAGES=(
  # bat bat-extras <- homebrew
  # fastfetch <- homebrew
  # fd-find fzf <- homebrew
  # pipewire-codec-aptx
  # ripgrep the_silver_searcher <- homebrew
  # starship <- homebrew
  NetworkManager-openvpn-gnome
  android-tools
  bootc
  code
  corectrl
  gcc
  input-leap
  input-remapper
  kitty
  libva-utils vdpauinfo
  lshw
  nvtop
  openssl
  # openssl1.1 <- removed in F40
  podman-compose
  python3-pip python3-pyyaml
  restic
  singularity-ce
  spice-gtk-tools socat
  steam
  subscription-manager
  virt-manager virt-viewer virt-install
  wl-clipboard
  xeyes
  xrandr
  zsh
)

EXCLUDED_PACKAGES=(
)

if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  EXCLUDED_PACKAGES=("$(rpm -qa --queryformat='%{NAME} ' "${EXCLUDED_PACKAGES[@]}")")
fi

if [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 && "${#EXCLUDED_PACKAGES[@]}" -eq 0 ]]; then
  rpm-ostree install "${INCLUDED_PACKAGES[@]}"

elif [[ "${#INCLUDED_PACKAGES[@]}" -eq 0 && "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  rpm-ostree override remove "${EXCLUDED_PACKAGES[@]}"

elif [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 && "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  # shellcheck disable=SC2046 disable=SC2068
  rpm-ostree override remove ${EXCLUDED_PACKAGES[@]} $(printf -- "--install=%s " ${INCLUDED_PACKAGES[@]})

else
  echo "No packages to install."

fi
