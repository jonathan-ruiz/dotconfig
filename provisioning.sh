#!/bin/bash

base_pacman_packages=(
    "firefox"     
    "neovim"
    # File browser
    "thunar"
    # Audio system
    "pulseaudio"
    "pasystray"
    "pavucontrol"
    "pulseaudio-bluetooth"
    "alsa-utils"
    # Screenshots
    "flameshot"    
    # System tools
    "polkit"
    "udev"
    "udisks2"
    "rsync"
    "xorg-xdpyinfo"
    "blueman"
    "acpi"
    "upower"
    "ttf-nerd-fonts-symbols-mono"
    # Terminal
    "lsd" 
    "kitty"
    "zsh"
    # Window manager 
    "redshift"
    "rofi"    
    "python-pywal"
    "calc"
    "i3"
    "polybar"
    "network-manager-applet"
)

extra_pacman_packages=(    
    # Graphic design tools
    "gimp" 
    "blender" 
    # Virtualization
    "virtualbox"    
    # Screen capturing 
    "obs-studio"     
    # Thunar extras
    "gvfs" 
    "thunar-archive-plugin" 
    "thunar-media-tags-plugin" 
    "thunar-shares-plugin" 
    "thunar-volman" 
    "ffmpegthumbnailer" 
    "tumbler" 
    "libgsf" 
    "gvfs-mtp" 
    "gvfs-smb" 
    "sshfs" 
    "catfish" 
    # udev extras
    "game-devices-udev" 
    "game-devices-udev" 
    # Editors
    "code"
)

base_aur_packages=(
    "jetbrains-toolbox" 
    "unityhub"     
)

extra_aur_packages=(    
    # Thunar extras
    "raw-thumbnailer" 
    "tumbler-extra-thumbnailers" 
    "tumbler-stl-thumbnailer" 
    "webp-pixbuf-loader"
)


install_packages() {
    echo -e "\e[1;32m\nInstalling extra...\e[0m"

    # Loop through the arguments passed to the function
    for pkg in "$@"; do
        if pacman -Q "$pkg" &>/dev/null; then
            echo "$pkg is already installed."
        else
            sudo pacman -Sy --noconfirm "$pkg"
            if [ $? -ne 0 ]; then
                echo -e "\e[1;31mError: Failed to install $pkg.\e[0m"
                exit 1
            fi
        fi
    done   
}

install_aur_packages() {
    echo -e "\e[1;32m\nInstalling AUR packages...\e[0m"

    # Loop through the arguments passed to the function
    for package_name in "$@"; do
        local temp_dir="$(mktemp -d)"
        echo -e "\e[1;32m\nInstalling $package_name AUR package...\e[0m"
        trap cleanup EXIT
        git clone "https://aur.archlinux.org/$package_name.git" "$temp_dir" || { echo -e "\e[1;31mError: Failed to clone AUR repository for $package_name.\e[0m"; exit 1; }
        cd "$temp_dir" || { echo -e "\e[1;31mError: AUR directory for $package_name not found.\e[0m"; exit 1; }
        makepkg -s -r -c --noconfirm || { echo -e "\e[1;31mError: Failed to build AUR package for $package_name.\e[0m"; exit 1; }
        sudo pacman -U --noconfirm "$package_name"*.tar.xz || { echo -e "\e[1;31mError: Failed to install AUR package $package_name.\e[0m"; exit 1; }
        echo -e "\e[1;32mInstallation of $package_name completed successfully.\e[0m"
    done
}

# Function to clean up temporary directories
cleanup() {
    if [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
        echo -e "\e[1;33mCleanup: Temporary directory '$temp_dir' removed.\e[0m"
    fi
}

# Script start
echo -e "\e[1;34m"
cat << "EOF"
      _._     _,-'""`-._
     (,-.`._,'(       |\`-/|
         `-.-' \ )-`( , o o)
               `-    \`_`"'-
EOF
echo -e "\e[0m"
echo -e "\e[1;32mWelcome to the Dotfiles Provisioning Script!\e[0m"
echo "This script will install necessary packages and configure powerlevel10k."
echo "Please ensure you have sudo privileges and run this script as a normal user."

# Check if the script is run as root
if [ "$(id -u)" -eq 0 ]; then
    echo -e "\e[1;31mError: This script should not be run as root. Please execute it as a normal user with sudo privileges.\e[0m"
    exit 1
fi

# Check if the OS is Arch or Arch-based
if ! command -v pacman &> /dev/null; then
    echo -e "\e[1;31mError: This script is designed for Arch Linux or Arch-based distributions.\e[0m"
    exit 1
fi

# Manjaro - Remove conflicting packages
if pacman -Qi i3status-manjaro &> /dev/null; then
    echo -e "\e[1;32m\nRemoving conflicting package: i3status-manjaro...\e[0m"
    sudo pacman -Rns --noconfirm i3status-manjaro manjaro-i3-settings
fi
if pacman -Qi manjaro-zsh-config &> /dev/null; then
    echo -e "\e[1;32m\nRemoving conflicting package: manjaro-zsh-config...\e[0m"
    sudo pacman -Rns --noconfirm manjaro-zsh-config 
fi

# Install required packages
echo -e "\e[1;32m\nInstalling necessary packages...\e[0m"
install_packages $base_pacman_packages
install_aur_packages $base_aur_packages

# Check if installation was successful
if [ $? -ne 0 ]; then
    echo -e "\e[1;31mError: Failed to install packages.\e[0m"
    exit 1
fi

# Install and configure powerlevel10k
echo -e "\e[1;32m\nInstalling and configuring powerlevel10k...\e[0m"
sudo pacman -R --noconfirm zsh-theme-powerlevel10k 
yay -S --noconfirm zsh-theme-powerlevel10k-git
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
echo -e "\e[1;32mPowerlevel10k installed and configured.\e[0m"

# Prompt user if they want to install browsing-related packages
read -p "Do you want to install extra packages? (y/n): " choice
case "$choice" in 
  y|Y ) install_packages $extra_pacman_packages && install_aur_packages $extra_aur_packages;;
  n|N ) echo -e "\e[1;32m\nNo extra packages will be installed.\e[0m";;
  * ) echo -e "\e[1;31mInvalid choice. No extra packages will be installed.\e[0m";;
esac

echo -e "\e[1;32m\nPackages installed successfully!\e[0m"
exit 0
