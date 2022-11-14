#!/usr/bin/bash

# Set the lines of the text that the file will contain
set_lines=(
    '# Avoid installing recommended packages'
    'APT::Install-Recommends "0";\n'

    '# Avoid installing suggest packages'
    'APT::Install-Suggests "0";\n'

    '# Install the Spanish translation packages'
    'Acquire::Languages { "environment", "es"; "en"; "none"; };\n'
)

# Print the lines in the files
printf "%b\n" "${set_lines[@]}" | sudo tee -i "/etc/apt/apt.conf.d/00apt"

# Set locale values and environment
sudo sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sudo sed -i 's/# es_CO.UTF-8/es_CO.UTF-8/' /etc/locale.gen
sudo locale-gen
locale_environment_vars=($(echo \
$(printf '%s=es_CO.UTF-8 ' LANG LANGUAGE) \
$(printf 'LC_%s=es_CO.UTF-8 ' MESSAGES) \
$(printf 'LC_%s=es_CO.UTF-8 ' CTYPE NUMERIC TIME COLLATE MONETARY PAPER NAME ADDRESS TELEPHONE MEASUREMENT IDENTIFICATION)
))
printf "%s\n" "${locale_environment_vars[@]}" | sudo tee -i "/etc/locale.conf"
sudo update-locale "${locale_environment_vars[@]}"
source /etc/locale.conf

sudo sed -i 's/https:\/\//http:\/\//' /etc/apt/sources.list
sudo apt update
sudo apt install --reinstall --fix-broken --no-install-suggests --no-install-recommends --purge -y \
apt-transport-https \
openssl \
gnupg2 \
ca-certificates
sudo sed -i 's/http:\/\//https:\/\//' /etc/apt/sources.list
sudo apt update
sudo apt dist-upgrade --reinstall --fix-broken --no-install-suggests --no-install-recommends --purge

sudo apt install --reinstall --fix-broken --no-install-suggests --no-install-recommends --purge -y \
	linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') \
    wget \
    curl \
    p7zip-full \
    p7zip-rar \
    rar \
    unrar \
    zip \
    unzip \
    unace \
    bzip2 \
    arj \
    lzip \
    lzma \
    gzip \
    unar \
    amd64-microcode \
    firmware-realtek \
    nvidia-kernel-dkms \
    nvidia-driver \
    libasound2 \
    pulseaudio \
    fonts-noto-color-emoji \
    bluez \
    pulseaudio-module-bluetooth \
    lsb-release \
    fzf \
    zsh \
    neovim \
    openssh-client \
    git \
    xserver-xorg-core \
    xserver-xorg-input-libinput \
    xserver-xorg-video-nvidia \
    redshift \
    policykit-1 \
	lxqt-policykit \
    numlockx \
    qlipper \
    dunst \
    rofi \
    python3 \
    python3-pip \
    pipenv \
    ranger \
    nvidia-settings \
    kitty \
    pavucontrol \
    flameshot \
    nautilus \
    blueman \
    polybar \
    lightdm \
    picom \
    feh \
    xautolock \
    lxappearance \
    lightdm-gtk-greeter \
    lightdm-gtk-greeter-settings \
    snapd \
    bspwm


echo 'pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $@' | sudo tee -i "/usr/bin/gksudo"
sudo chmod +x /usr/bin/gksudo

sudo usermod -a -G bluetooth pulse

# Enable Pulseaudio
systemctl --user enable pulseaudio
pulseaudio -D
pulseaudio --start
systemctl --user start pulseaudio

# Enable Bluetooth
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# Kill a running daemon PulseAudio
pulseaudio -k

echo "greeter-setup-script=$(which numlockx) on" | sudo tee -a "/usr/share/lightdm/lightdm.conf.d/01_debian.conf"

sudo wget https://github.com/jdgomezh/debian-bspwm-post-install/blob/3eea22421516e8952bee911fa720cbf84f496b3c/xorg.conf -O /etc/X11/xorg.conf

sudo snap install core
sudo snap install brave
