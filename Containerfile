ARG SOURCE_IMAGE="${SOURCE_IMAGE}"

################################### os #########################################
FROM ${SOURCE_IMAGE} AS os

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

################################### os-dx ######################################
FROM os AS os-dx

COPY dx/etc /etc

RUN echo "Customising packages..." && \
      rpm-ostree install --idempotent --enablerepo fedora,updates,updates-archive \
        direnv \
        fd-find ripgrep the_silver_searcher \
        input-remapper \
        kitty \
        lm_sensors \
        nvtop \
        podman-compose podmansh podman-tui \
        python3-pip \
        subscription-manager \
      && \
      systemctl enable cpupower.service && \
      systemctl enable input-remapper.service && \
      systemctl enable nix.mount && \
      systemctl enable podman.socket && \
    echo "...done!"

RUN echo "Installing Inter font..." && \
      curl -sL $(curl -s https://api.github.com/repos/rsms/inter/releases | jq -r '.[0].assets[0].browser_download_url') -o /tmp/inter.zip && \
      mkdir -p /tmp/inter /usr/share/fonts/inter && \
      unzip /tmp/inter.zip -d /tmp/inter/ && \
      mv /tmp/inter/*.ttf /tmp/inter/*.ttc /tmp/inter/LICENSE.txt /usr/share/fonts/inter/ && \
      fc-cache -f /usr/share/fonts/inter && \
    echo "...done!"

RUN echo "Clean up and commit..." && \
      rm -rf /tmp/* /var/* && \
      ostree container commit && \
      mkdir -p /var/tmp && chmod -R 1777 /var/tmp && \
    echo "...done!"
