ARG FEDORA_MAJOR_VERSION=37

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}

RUN rpm-ostree override remove firefox firefox-langpacks && \

RUN rm -rf \
      /tmp/* \
      /var/* && \
    ostree container commit
