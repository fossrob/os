#!/bin/bash
# shellcheck disable=SC2016

set -ouex pipefail

REPO='
[tailscale-stable]
name=Tailscale stable
baseurl=https://pkgs.tailscale.com/stable/fedora/$basearch
enabled=1
type=rpm
repo_gpgcheck=1
gpgcheck=0
gpgkey=https://pkgs.tailscale.com/stable/fedora/repo.gpg
'

cat > /etc/yum.repos.d/tailscale.repo <<< "$REPO"
rpm-ostree install tailscale
rm -f /etc/yum.repos.d/tailscale.repo

systemctl enable tailscaled.service
