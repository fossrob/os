#!/bin/sh

set -ouex pipefail

INCLUDED_PACKAGES=(
  adobe-source-code-pro-fonts google-droid-sans-mono-fonts google-go-mono-fonts ibm-plex-mono-fonts
    jetbrains-mono-fonts-all mozilla-fira-mono-fonts powerline-fonts
  bitstreamverasansmono-nerd-fonts cascadiacode-nerd-fonts dejavusansmono-nerd-fonts droidsansmono-nerd-fonts
    firacode-nerd-fonts firamono-nerd-fonts hack-nerd-fonts ibmplexmono-nerd-fonts inconsolata-nerd-fonts
    jetbrainsmono-nerd-fonts liberationmono-nerd-fonts meslo-nerd-fonts nerdfontssymbolsonly-nerd-fonts noto-nerd-fonts
    robotomono-nerd-fonts sourcecodepro-nerd-fonts ubuntumono-nerd-fonts
  bat bat-extras cheat cheat-bash-completion cheat-zsh-completion duf exa git-delta fd-find fzf ripgrep the_silver_searcher
  hplip hplip-gui
  input-remapper
  just
  kitty
  lm_sensors nvtop powertop tlp tlp-rdw
  podman-compose podmansh
  python3-pip
  starship
  subscription-manager
  tailscale
  tmux
  vim
  zsh
  adw-gtk3-theme
  gnome-tweaks
  raw-thumbnailer

  alsa-firmware
  apr
  apr-util
  ffmpeg
  ffmpeg-libs
  ffmpegthumbnailer
  grub2-tools-extra
  heif-pixbuf-loader
  intel-media-driver
  kernel-devel-matched
  kernel-tools
  libheif-freeworld
  libheif-tools
  libratbag-ratbagd
  libva-intel-driver
  libva-utils
  lshw
  mesa-va-drivers-freeworld
  net-tools
  nvme-cli
  nvtop
  openssl
  pipewire-codec-aptx
  smartmontools
  symlinks
  tcpdump
  tmux
  traceroute
  vim
  zstd
  wireguard-tools
)

EXCLUDED_PACKAGES=(
  distrobox
  fedora-repos-modular
  firefox firefox-langpacks mozilla-openh264
  fzf htop
  gnome-classic-session
  gnome-initial-setup
  gnome-software gnome-software-rpm-ostree
  gnome-tour
  supergfxctl gnome-shell-extension-supergfxctl-gex dconf-editor
  libavcodec-free libavdevice-free libavfilter-free libavformat-free libavutil-free libpostproc-free libswresample-free libswscale-free mesa-va-drivers
)

# for repo in $(ls /etc/yum.repos.d/*.repo); do
#   sed -i $repo -e 's/enabled=1/enabled=0/'
# done

# if [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 ]]; then
#   rpm-ostree install --idempotent --enablerepo fedora,updates,updates-archive,tailscale-stable,terra ${INCLUDED_PACKAGES[@]}
# fi

if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
  EXCLUDED_PACKAGES=($(rpm -qa --queryformat='%{NAME} ' ${EXCLUDED_PACKAGES[@]}))
fi

if [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 && "${#EXCLUDED_PACKAGES[@]}" -eq 0 ]]; then
    rpm-ostree install \
        ${INCLUDED_PACKAGES[@]}

elif [[ "${#INCLUDED_PACKAGES[@]}" -eq 0 && "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    rpm-ostree override remove \
        ${EXCLUDED_PACKAGES[@]}

elif [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 && "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    rpm-ostree override remove \
        ${EXCLUDED_PACKAGES[@]} \
        $(printf -- "--install=%s " ${INCLUDED_PACKAGES[@]})

else
    echo "No packages to install."

fi
