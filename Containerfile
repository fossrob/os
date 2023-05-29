ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"


################################### os #########################################
FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS os

COPY etc /etc

RUN echo "removing packages..." && \
      rpm-ostree override remove \
        firefox firefox-langpacks \
        gnome-software gnome-software-rpm-ostree \
        gnome-tour \
      && \
    echo "done"

RUN echo "installing packages..." && \
      rpm-ostree install \
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

RUN

################################### os-ux ######################################
FROM os AS os-ux


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
        lm_sensors \
        openssl \
        python3-pip \
      && \
    echo "done"

RUN /scripts/protonvpn.sh || true

# This will only affect new installations...
RUN echo "service configuration" && \
      systemctl enable cpupower.service && \
      systemctl enable nix.mount && \
    echo "done"

RUN echo "clean up & commit..." $$ \
      rm -rf /scripts /tmp/* /var/* && \
      ostree container commit && \
    echo "done"
