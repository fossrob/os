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

#
# sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-{cisco-openh264,modular,updates-modular}.repo
#
# rpm-ostree install --idempotent https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# rpm-ostree install --idempotent akmod-nvidia*:535.*.fc38.x86_64 xorg-x11-drv-nvidia-{,cuda,devel,kmodsrc,power}*:535.*.fc38.x86_64
#
# ln -s /usr/bin/ld.bfd /etc/alternatives/ld && ln -s /etc/alternatives/ld /usr/bin/ld
# ln -s /usr/bin/rpm-ostree /usr/bin/dnf
#
