ARG FEDORA_MAJOR_VERSION=37

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}

COPY etc /etc

RUN rpm-ostree override remove firefox firefox-langpacks

RUN rpm-ostree install \
      distrobox \
      gnome-shell-extension-appindicator \
      gnome-tweaks \
      kitty kitty-bash-integration kitty-doc \
      lm_sensors \
      openssl \
      tailscale \
      vim \
      virt-manager \
    ;

RUN echo "service configuration" && \
      systemctl enable tailscaled.service && \
    echo "done"

RUN echo "clean up" $$ \
      rm -f /etc/yum.repos.d/tailscale.repo && \
      rm -rf /tmp/* /var/* && \
    echo "done"

RUN ostree container commit
