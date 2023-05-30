#!/bin/bash
# shellcheck disable=SC2016

PROTON_REPO_DEFINITION='
[protonvpn-fedora-stable]
name=ProtonVPN Fedora Stable repository
baseurl=https://repo.protonvpn.com/fedora-$releasever-stable
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://repo.protonvpn.com/fedora-$releasever-stable/public_key.asc
'

eval "$(grep '^VERSION_ID' /etc/os-release)"

PROTON_REPO_STATUS=$(
  curl --silent --include --output /dev/null --write-out "%{http_code}" \
    --url "https://repo.protonvpn.com/fedora-${VERSION_ID}-stable/public_key.asc"
)

if [[ $PROTON_REPO_STATUS -eq 200 ]]; then
  cat > /etc/yum.repos.d/protonvpn.repo <<< "$PROTON_REPO_DEFINITION"
  rpm-ostree install protonvpn
  rm -f /etc/yum.repos.d/protonvpn-stable.repo
fi
