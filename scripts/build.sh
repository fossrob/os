#!/usr/bin/env bash
# shellcheck disable=SC2207
set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

INCLUDED_PACKAGES=($(jq -r "[ select(.\"$IMAGE_NAME\" != null).\"$IMAGE_NAME\".include[], select(.\"$RELEASE\" != null).\"$RELEASE\".include[] ] | sort | unique[]" /tmp/packages.json))
EXCLUDED_PACKAGES=($(jq -r "[ select(.\"$IMAGE_NAME\" != null).\"$IMAGE_NAME\".exclude[], select(.\"$RELEASE\" != null).\"$RELEASE\".exclude[] ] | sort | unique[]" /tmp/packages.json))

if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    EXCLUDED_PACKAGES=($(rpm -qa --queryformat='%{NAME} ' "${EXCLUDED_PACKAGES[@]}"))
fi

LOCAL_PACKAGES=()

if [[ -d /tmp/rpms ]]; then
    for PACKAGE_FILE in /tmp/rpms/*.rpm; do
        PACKAGE_NAME="$(rpm -q --nosignature --queryformat='%{NAME}\n' "$PACKAGE_FILE")"
        rpm -q "$PACKAGE_NAME" || LOCAL_PACKAGES+=("$PACKAGE_FILE")
    done
fi

rpm -q fedora-repos-archive || LOCAL_PACKAGES+=("fedora-repos-archive")

[[ "${#LOCAL_PACKAGES[@]}" -gt 0 ]] && rpm-ostree install "${LOCAL_PACKAGES[@]}"

if [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 && "${#EXCLUDED_PACKAGES[@]}" -eq 0 ]]; then
    rpm-ostree install "${INCLUDED_PACKAGES[@]}"
elif [[ "${#INCLUDED_PACKAGES[@]}" -eq 0 && "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    rpm-ostree override remove "${EXCLUDED_PACKAGES[@]}"
elif [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 && "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    rpm-ostree override remove "${EXCLUDED_PACKAGES[@]}" $(printf -- "--install=%s " "${INCLUDED_PACKAGES[@]}")
else
    echo "No packages to install."
fi
