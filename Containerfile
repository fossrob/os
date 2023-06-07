ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"
ARG BASE_IMAGE="ghcr.io/ublue-os/silverblue-${IMAGE_FLAVOR}"

################################### os #########################################
FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS os

COPY etc /etc

RUN for repo in $(ls /etc/yum.repos.d/*.repo); do sed -i $repo -e 's/enabled=1/enabled=0/'; done

RUN echo "Customising packages..." && \
      rpm-ostree override remove \
        firefox firefox-langpacks \
        fzf \
        gnome-initial-setup \
        gnome-software gnome-software-rpm-ostree \
        gnome-tour \
        htop \
        nvtop \
      && \
      rpm-ostree install --idempotent --enablerepo fedora,updates,tailscale-stable \
        gnome-shell-extension-appindicator \
        gnome-shell-extension-blur-my-shell \
        gnome-shell-extension-caffeine \
        gnome-shell-extension-dash-to-dock \
        gnome-shell-extension-dash-to-panel \
        gnome-shell-extension-just-perfection \
        kitty-terminfo \
        powertop \
        tailscale \
        yaru-theme \
      && \
      systemctl enable tailscaled.service && \
    echo "...done!"

RUN echo "Clean up and commit..." && \
      rm -f /etc/yum.repos.d/tailscale.repo && \
      rm -rf /tmp/* /var/* && \
      ostree container commit && \
      mkdir -p /var/tmp && chmod -R 1777 /var/tmp && \
    echo "...done!"

################################### os-dx ######################################
FROM os AS os-dx

COPY dx/etc /etc

RUN echo "Customising packages..." && \
      rpm-ostree install --idempotent --enablerepo fedora,updates \
        kitty \
        libgda libgda-sqlite \
        nvtop \
        podman-compose \
        python3-pip \
      && \
      rpm-ostree install --idempotent --enablerepo fedora,updates \
        edk2-tools \
        genisoimage \
        lsb \
        procps \
        qemu \
        socat \
        spice-gtk-tools \
        swtpm \
        xrandr \
      && \
      systemctl enable cpupower.service && \
      systemctl enable nix.mount && \
    echo "...done!"

RUN echo "Clean up and commit..." && \
      rm -rf /tmp/* /var/* && \
      ostree container commit && \
      mkdir -p /var/tmp && chmod -R 1777 /var/tmp && \
    echo "...done!"
