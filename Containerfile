ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG MAJOR_VERSION="${MAJOR_VERSION:-38}"
ARG UPSTREAM="ghcr.io/ublue-os/silverblue-${IMAGE_FLAVOR}:${MAJOR_VERSION}"


################################### os #########################################
FROM ${UPSTREAM} AS os

COPY etc /etc

RUN echo "removing packages..." && \
      rpm-ostree override remove \
        firefox firefox-langpacks \
        htop nvtop \
        gnome-software gnome-software-rpm-ostree \
        gnome-tour \
      && \
    echo "done"

RUN echo "installing packages..." && \
      rpm-ostree install \
        lm_sensors \
        tailscale \
      && \
    echo "done"

RUN echo "service configuration..." && \
      systemctl enable tailscaled.service && \
    echo "done"

RUN echo "clean up & commit..." $$ \
      rm -f /etc/yum.repos.d/tailscale.repo && \
      rm -rf /scripts /tmp/* /var/* && \
      ostree container commit && \
    echo "done"

################################### os-ux ######################################
FROM os AS os-ux

# Dash to panel
# Browser
# Desktop icons
# X11

RUN ostree container commit

################################### os-dx ######################################
FROM os AS os-dx

COPY dx/etc /etc
COPY scripts /scripts

RUN echo "installing packages..." && \
      rpm-ostree install \
        gtk-murrine-engine gtk2-engines \
        kitty kitty-bash-integration kitty-doc \
        libgda libgda-sqlite \
        openssl \
        htop nvtop \
        python3-pip \
      && \
    echo "done"

RUN /scripts/protonvpn.sh || true

RUN echo "service configuration" && \
      systemctl enable cpupower.service && \
      systemctl enable nix.mount && \
    echo "done"

RUN echo "clean up & commit..." $$ \
      rm -rf /scripts /tmp/* /var/* && \
      ostree container commit && \
    echo "done"
