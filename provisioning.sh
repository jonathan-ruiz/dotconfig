#!/bin/bash

# Function to install Firefox
install_extra() {
    echo -e "\e[1;32m\nInstalling extra...\e[0m"
    packages=("firefox" "gimp" "blender" "virtualbox" "neovim")

    for pkg in "${packages[@]}"; do
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

    # Aur
    echo -e "\e[1;32m\nInstalling AUR packages...\e[0m"
    git clone --branch jetbrains-toolbox --single-branch https://github.com/archlinux/aur.git || { echo -e "\e[1;31mError: Failed to clone AUR repository.\e[0m"; exit 1; }
    cd aur || { echo -e "\e[1;31mError: AUR directory not found.\e[0m"; exit 1; }
    makepkg || { echo -e "\e[1;31mError: Failed to build AUR package.\e[0m"; exit 1; }
    sudo pacman -U --noconfirm jetbrains-toolbox*.xz || { echo -e "\e[1;31mError: Failed to install AUR package.\e[0m"; exit 1; }
    cd .. || { echo -e "\e[1;31mError: Failed to change directory.\e[0m"; exit 1; }
    rm -rf aur || { echo -e "\e[1;31mError: Failed to remove AUR directory.\e[0m"; exit 1; }
}

# ASCII art and instructions
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
sudo pacman -Sy --noconfirm \
    rsync \
    lsd \
    xorg-xdpyinfo \
    redshift \
    rofi \
    python-pywal \
    calc \
    kitty \
    zsh \
    i3 \
    polybar \
    network-manager-applet \
    blueman \
    alsa-utils \
    acpi \
    upower \
    ttf-nerd-fonts-symbols-mono

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
  y|Y ) install_extra;;
  n|N ) echo -e "\e[1;32m\nNo extra packages will be installed.\e[0m";;
  * ) echo -e "\e[1;31mInvalid choice. No extra packages will be installed.\e[0m";;
esac

echo -e "\e[1;32m\nPackages installed successfully!\e[0m"
exit 0
