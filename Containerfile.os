ARG SOURCE_IMAGE="${SOURCE_IMAGE}"

FROM ${SOURCE_IMAGE}

COPY etc /etc
COPY usr /usr

RUN for repo in $(ls /etc/yum.repos.d/*.repo); do sed -i $repo -e 's/enabled=1/enabled=0/'; done

RUN echo "Customising packages..." && \
      rpm-ostree override remove \
        distrobox \
        firefox firefox-langpacks \
        fzf \
        gnome-initial-setup \
        gnome-classic-session \
        gnome-software gnome-software-rpm-ostree \
        gnome-tour \
        htop \
        nvtop \
      && \
      rpm-ostree install --idempotent --enablerepo fedora,updates,updates-archive,tailscale-stable \
        baobab \
        gnome-shell-extension-appindicator \
        gnome-shell-extension-dash-to-panel \
        gnome-shell-extension-just-perfection \
        hplip hplip-gui \
        kitty-terminfo \
        powertop \
        tailscale \
        yaru-theme \
      && \
      systemctl unmask dconf-update.service && \
      systemctl enable dconf-update.service && \
      systemctl enable tailscaled.service && \
    echo "...done!"

RUN echo "Clean up and commit..." && \
      rm -f /etc/yum.repos.d/tailscale.repo && \
      rm -rf /tmp/* /var/* && \
      ostree container commit && \
      mkdir -p /var/tmp && chmod -R 1777 /var/tmp && \
    echo "...done!"
