#!/usr/bin/env bash
set -ouex pipefail

INCLUDED_PACKAGES=(
  gnome-shell-extension-dash-to-panel
  gnome-shell-extension-user-theme
  pipewire-codec-aptx
  powertop
  tlp tlp-rdw
  yaru-theme
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
