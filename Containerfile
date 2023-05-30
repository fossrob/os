ARG FEDORA_VERSION="${FEDORA_VERSION:-38}"
ARG UPSTREAM="${UPSTREAM:-quay.io/fedora-ostree-desktops/silverblue}"

################################### os #########################################
FROM ${UPSTREAM}:${FEDORA_VERSION} AS os

ARG IMAGE_NAME="os"
ARG FEDORA_VERSION="${FEDORA_VERSION}"

COPY etc /etc

ADD scripts/* /tmp/
ADD packages.json /tmp/

COPY --from=ghcr.io/ublue-os/config:latest /rpms /tmp/rpms

ADD https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm /tmp/rpms/
ADD https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm /tmp/rpms/

RUN /tmp/build.sh
RUN /tmp/tailscale.sh
RUN rm -rf /tmp/* /var/*
RUN ostree container commit
RUN mkdir -p /var/tmp && chmod -R 1777 /var/tmp

################################### os-ux ######################################
FROM os AS os-ux

ARG IMAGE_NAME="os-ux"
ARG FEDORA_VERSION="${FEDORA_VERSION}"

ADD scripts/* /tmp/
ADD packages.json /tmp/packages.json

RUN /tmp/build.sh
RUN rm -rf /tmp/* /var/*
RUN ostree container commit
RUN mkdir -p /var/tmp && chmod -R 1777 /var/tmp

################################### os-dx ######################################
FROM os AS os-dx

ARG IMAGE_NAME="os-dx"
ARG FEDORA_VERSION="${FEDORA_VERSION}"

# COPY dx/etc /etc
COPY scripts /scripts

ADD scripts/* /tmp/
ADD packages.json /tmp/packages.json

RUN /tmp/build.sh
RUN rm -rf /tmp/* /var/*
RUN ostree container commit
RUN mkdir -p /var/tmp && chmod -R 1777 /var/tmp

# RUN echo "service configuration" && \
#       systemctl enable cpupower.service && \
#       systemctl enable nix.mount && \
#     echo "done"
