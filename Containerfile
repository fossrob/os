ARG SOURCE_IMAGE=ghcr.io/ublue-os/silverblue-main

FROM $SOURCE_IMAGE

RUN rpm-ostree override remove firefox firefox-langpacks gnome-software gnome-software-rpm-ostree

COPY etc /etc

RUN rpm-ostree install \
      distrobox \
      gnome-shell-extension-appindicator gnome-tweaks \
      kitty kitty-bash-integration kitty-doc \
      just \
      lm_sensors \
      openssl \
      nvtop \
      tailscale \
      vim \
      virt-manager \
    ;

# This will only affect new installations...
RUN echo "configuration customisation" && \
      sed -e 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' -i /etc/rpm-ostreed.conf && \
    echo "done"

# This will only affect new installations...
RUN echo "service configuration" && \
      systemctl enable tailscaled.service && \
    echo "done"

RUN echo "clean up" $$ \
      rm -f /etc/yum.repos.d/tailscale.repo && \
      rm -rf /tmp/* /var/* && \
    echo "done"

RUN ostree container commit
