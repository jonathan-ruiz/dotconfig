#!/bin/bash

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

# Install required packages
echo -e "\e[1;32m\nInstalling necessary packages...\e[0m"
sudo pacman -Sy --noconfirm \
    rsync \
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

echo -e "\e[1;32m\nPackages installed successfully!\e[0m"
exit 0
