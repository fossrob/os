ARG SOURCE_IMAGE=ghcr.io/ublue-os/silverblue-main

FROM $SOURCE_IMAGE

#RUN echo "rpm fusion updates..." && \
#      rpm-ostree refresh-md && \
#      rpm-ostree install \
#        ffmpeg \
#        gstreamer1-plugin-libav \
#        gstreamer1-plugins-bad-free-extras \
#        gstreamer1-plugins-bad-freeworld \
#        gstreamer1-plugins-ugly \
#        gstreamer1-vaapi \
#        mesa-va-drivers-freeworld \
#        mesa-vdpau-drivers-freeworld \
#       && \
#    echo "done"

RUN rpm-ostree override remove \
      firefox firefox-langpacks \
      gnome-software gnome-software-rpm-ostree \
      gnome-disk-utility gnome-tour \
    ;

COPY etc /etc
COPY scripts /scripts

COPY --from=ghcr.io/ublue-os/config:latest /files/ublue-os-udev-rules /
COPY --from=ghcr.io/ublue-os/config:latest /files/ublue-os-update-services /

RUN echo "installing packages..." && \
      rpm-ostree install \
        distrobox \
        gtk-murrine-engine gtk2-engines \
        gnome-tweaks \
        kitty kitty-bash-integration kitty-doc \
        kernel-tools \
        lm_sensors \
        openssl \
        python3-pip \
        nvtop \
        tailscale \
        vim \
      && \
    echo "done"

RUN /scripts/protonvpn.sh

# This will only affect new installations...
RUN echo "configuration customisation" && \
      sed -e 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' -i /etc/rpm-ostreed.conf && \
    echo "done"

# This will only affect new installations...
RUN echo "service configuration" && \
      systemctl enable nix.mount && \
      systemctl enable tailscaled.service && \
    echo "done"

RUN echo "clean up" $$ \
      rm -f /etc/yum.repos.d/protonvpn-stable.repo && \
      rm -f /etc/yum.repos.d/tailscale.repo && \
      rm -rf /scripts /tmp/* /var/* && \
    echo "done"

RUN ostree container commit
