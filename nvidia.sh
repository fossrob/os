#!/bin/sh

set -ouex pipefail

install -D /tmp/ublue-os-nvidia-addons/rpmbuild/SOURCES/nvidia-container-runtime.repo \
    /etc/yum.repos.d/nvidia-container-runtime.repo

source /var/cache/akmods/nvidia-vars

rpm-ostree install \
    xorg-x11-drv-${NVIDIA_PACKAGE_NAME}-{,cuda-,devel-,kmodsrc-,power-}${NVIDIA_FULL_VERSION} \
    nvidia-container-toolkit nvidia-vaapi-driver \
    /var/cache/akmods/${NVIDIA_PACKAGE_NAME}/kmod-${NVIDIA_PACKAGE_NAME}-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm \
    /tmp/ublue-os-nvidia-addons/rpmbuild/RPMS/noarch/ublue-os-nvidia-addons-*.rpm

# akmod-nvidia*:535.*.fc38.x86_64
# xorg-x11-drv-nvidia-{,cuda,devel,kmodsrc,power}*:535.*.fc38.x86_64
