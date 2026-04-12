#!/bin/bash
set -euo pipefail

config=$(readlink -f ~/.config)

# --- Distro Detection ---
detect_distro() {
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        DISTRO=$ID
    else
        echo "Error: /etc/os-release not found. Cannot detect distro."
        exit 1
    fi
}

# --- Package Manager Abstraction ---
pkg_update() {
    case $DISTRO in
        ubuntu|debian) sudo apt update ;;
        arch|manjaro)  sudo pacman -Syu ;;
        *) echo "Unsupported distro: $DISTRO"; exit 1 ;;
    esac
}

pkg_install() {
    case $DISTRO in
        ubuntu|debian) sudo apt install -y "$@" ;;
        arch|manjaro)  sudo pacman -S --noconfirm "$@" ;;
        *) echo "Unsupported distro: $DISTRO"; exit 1 ;;
    esac
}

# For AUR packages on Arch — requires yay or paru to be installed
aur_install() {
    if command -v yay &>/dev/null; then
        yay -S --noconfirm "$@"
    elif command -v paru &>/dev/null; then
        paru -S --noconfirm "$@"
    else
        echo "Warning: No AUR helper found (yay/paru). Please manually install: $*"
    fi
}

# --- VMware Detection ---
is_vmware() {
    systemd-detect-virt 2>/dev/null | grep -qi vmware
}

install_vmware_tools() {
    if ! is_vmware; then
        return
    fi
    echo "VMware guest detected — installing open-vm-tools..."
    case $DISTRO in
        ubuntu|debian) pkg_install open-vm-tools open-vm-tools-desktop ;;
        arch|manjaro)  pkg_install open-vm-tools ;;
    esac
    sudo systemctl enable --now vmtoolsd.service

    # Disable resolutionKMS in the system service.
    # libresolutionSet.so (user-level plugin) detects libdrm.so.2 and backs
    # off to the KMS path, but KMS resize never propagates back to X11.
    # We use vmware-xrandr-watch instead (see scripts/vmware-xrandr-watch).
    sudo mkdir -p /etc/vmware-tools
    printf '[resolutionKMS]\nenable=false\n' | sudo tee /etc/vmware-tools/tools.conf > /dev/null

    # Install the xrandr watcher script
    sudo cp scripts/vmware-xrandr-watch /usr/local/bin/vmware-xrandr-watch
    sudo chmod +x /usr/local/bin/vmware-xrandr-watch
}

# --- Tool Installation ---
install_i3() {
    case $DISTRO in
        ubuntu|debian)
            pkg_install \
                i3 \
                dmenu \
                alacritty \
                dex \
                xss-lock \
                network-manager-gnome \
                pulseaudio-utils \
                xsettingsd \
                picom \
                x11-xserver-utils
            ;;
        arch|manjaro)
            pkg_install \
                i3 \
                dmenu \
                alacritty \
                dex \
                xss-lock \
                network-manager-applet \
                pipewire-pulse \
                picom \
                xorg-xset \
                i3status-rust \
                ttf-font-awesome
            # xsettingsd is AUR on Arch
            aur_install xsettingsd
            ;;
    esac
}

install_nvim() {
    case $DISTRO in
        arch|manjaro)
            pkg_install neovim
            ;;
        ubuntu|debian)
            # Debian/Ubuntu repos ship very old Neovim, so pull the latest appimage
            local arch
            arch=$(uname -m)
            if [ "$arch" == "aarch64" ]; then arch='arm64'; fi
            pkg_install curl wget
            local latest
            latest=$(basename "$(curl -Ls -o /dev/null -w '%{url_effective}' https://github.com/neovim/neovim/releases/latest)")
            wget "https://github.com/neovim/neovim/releases/download/$latest/nvim-linux-$arch.appimage"
            chmod +x nvim-linux*
            mkdir -p ~/.local/bin
            mv nvim-linux* ~/.local/bin/nvim
            ;;
    esac
}

install_tmux() {
    pkg_install tmux
}

# --- Main ---
detect_distro
echo "Detected distro: $DISTRO"
pkg_update
install_vmware_tools

# Uncomment tools you want to install/configure
tools=()
tools+=("gtk-3.0")
tools+=("i3")
tools+=("i3status-rust")
tools+=("nvim")
tools+=("tmux")

for tool in "${tools[@]}"; do
    echo "Installing $tool..."
    case $tool in
        i3)   install_i3 ;;
        nvim) install_nvim ;;
        tmux) install_tmux ;;
    esac

    if [ ! -d "$config/$tool" ]; then
        mkdir -p "$config/$tool"
    fi

    echo "Placing config for $tool in $config/$tool"
    cp -R "$tool/"* "$config/$tool/"
done
