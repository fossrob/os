#!/usr/bin/env bash
set -ouex pipefail

INCLUDED_PACKAGES=(
  NetworkManager-openvpn-gnome
  android-tools
  bat bat-extras fd-find fzf ripgrep the_silver_searcher
  code
  fastfetch
  input-remapper
  kitty
  libva-utils
  lshw
  openssl
  powertop
  python3-pip python3-pyyaml
  starship
  subscription-manager
  tlp tlp-rdw
  virt-manager virt-viewer
  wl-clipboard
  xeyes
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
