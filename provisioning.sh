#!/bin/bash

# Check if the script was run with the '-y' or '--yes' option
if [[ $1 == '-y' || $1 == '--yes' ]]; then
    auto_confirm=true
else
    auto_confirm=false
fi


devops_pacman_packages=(
  "docker"
  "docker-compose"
  "sops"
  "remmina"
  "freerdp"
  "terraform"
  "vagrant"
)
devops_aur_packages=(
)

art_pacman_packages=(
  "gimp"
  "blender"
  "inkscape"
  "unityhub"
)
art_aur_packages=(
)

communications_pacman_packages=(
  "discord"
  "telegram-desktop"
  #"teams" # It's easier to install using edge and add app button
  "microsoft-edge-stable-bin"
)
communications_aur_packages=(
  "slack-desktop"
  "zoom"
)

coding_pacman_packages=(
  "code"
)
coding_aur_packages=(
  "jetbrains-toolbox" # Needed to download and rewrite executable
)

base_pacman_packages=(
  "firefox"
  "zip"
  # Audio system
  "pulseaudio"
  "pasystray"
  "pavucontrol"
  "pulseaudio-bluetooth"
  "alsa-utils"
  # Screenshots
  "flameshot"
  # System tools
  "less" # Git log pagination :O
  "vlc"
  "git"
  "base-devel"
  "neovim"
  "bluez"
  "bluez-utils"
  "xorg-server"
  "lightdm"
  "lightdm-gtk-greeter"
  "networkmanager"
  "fuse2"
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
  "dmenu"
  "cbatticon"
  "redshift"
  "rofi"
  "python-pywal"
  "calc"
  "i3"
  "polybar"
  "network-manager-applet"
  "gxkb"
)

extra_pacman_packages=(
    "virtualbox"
    "obs-studio"
    # Thunar
    "thunar"
    "gvfs" 
    "thunar-archive-plugin" 
    "thunar-media-tags-plugin"
    "thunar-volman" 
    "ffmpegthumbnailer" 
    "tumbler" 
    "libgsf" 
    "gvfs-mtp" 
    "gvfs-smb" 
    "sshfs" 
    "catfish"
)

base_aur_packages=(
    "mongodb-compass"
    "yay"
    #"mons"
)

extra_aur_packages=(    
    # Thunar extras
    "thunar-shares-plugin"
    "raw-thumbnailer" 
    "tumbler-extra-thumbnailers" 
    "tumbler-stl-thumbnailer" 
    "webp-pixbuf-loader"
    # udev extras
    "game-devices-udev"
)


install_packages() {
    echo -e "\e[1;32m\nInstalling pacman packages...\e[0m"

    # Loop through the arguments passed to the function
    for pkg in "$@"; do
        if pacman -Q "$pkg" &>/dev/null; then
            echo -e "\e[1;33m$pkg is already installed.\e[0m"
        else
            sudo pacman -Sy --noconfirm --needed "$pkg"
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
        local temp_dir=$package_name
        # Check if package is already installed
        if pacman -Qq "$package_name" &>/dev/null; then
            echo -e "\e[1;33m\n$package_name is already installed. Skipping...\e[0m"
        else
            echo -e "\e[1;32m\nInstalling $package_name AUR package...\e[0m"
            trap cleanup EXIT
            git clone https://aur.archlinux.org/${package_name}.git
            cd $package_name
            makepkg -si --noconfirm
            echo -e "\e[1;32mInstallation of $package_name completed successfully.\e[0m"
        fi
    done
}

prompt_install_packages() {
    local title=$1
    local pacman_packages=("${!2}")
    local aur_packages=("${!3}")
    echo -e "\e[1;34m$title\e[0m"
    if [ "$auto_confirm" = true ]; then
        choice='y'
    else
        read -p "Do you want to install these packages? (y/n): " choice
    fi
    case "$choice" in
        y|Y ) install_packages "${pacman_packages[@]}" && install_aur_packages "${aur_packages[@]}";;
        n|N ) echo -e "\e[1;32m\nNo packages will be installed.\e[0m";;
        * ) echo -e "\e[1;31mInvalid choice. No packages will be installed.\e[0m";;
    esac
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
install_packages ${base_pacman_packages[@]}
install_aur_packages ${base_aur_packages[@]}

# Check if installation was successful
if [ $? -ne 0 ]; then
    echo -e "\e[1;31mError: Failed to install packages.\e[0m"
    exit 1
fi

# Call the function for each package list
prompt_install_packages "Extra Packages" extra_pacman_packages[@] extra_aur_packages[@]
prompt_install_packages "DevOps Packages" devops_pacman_packages[@] devops_aur_packages[@]
prompt_install_packages "Art Packages" art_pacman_packages[@] art_aur_packages[@]
prompt_install_packages "Communications Packages" communications_pacman_packages[@] communications_aur_packages[@]
prompt_install_packages "Coding Packages" coding_pacman_packages[@] coding_aur_packages[@]

# Install and configure powerlevel10k
if [ -f ~/.p10k.zsh ]; then
    echo -e "\e[1;33mPowerlevel10k is already installed. Skipping installation.\e[0m"
else
    # Install and configure powerlevel10k
    echo -e "\e[1;32m\nInstalling and configuring powerlevel10k...\e[0m"
    sudo pacman -R --noconfirm zsh-theme-powerlevel10k
    yay -S --noconfirm zsh-theme-powerlevel10k-git
    echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
    echo -e "\e[1;32mPowerlevel10k installed and configured.\e[0m"
fi

## Prompt user if they want to install browsing-related packages
#read -p "Do you want to install extra packages? (y/n): " choice
#case "$choice" in
#  y|Y ) install_packages ${extra_pacman_packages[@]} && install_aur_packages ${extra_aur_packages[@]};;
#  n|N ) echo -e "\e[1;32m\nNo extra packages will be installed.\e[0m";;
#  * ) echo -e "\e[1;31mInvalid choice. No extra packages will be installed.\e[0m";;
#esac

echo -e "\e[1;32m\nPackages installed successfully!\e[0m"
cat << "EOF"
                 ____
                /____ `\
               ||_  _`\ \
         .-.   `|O, O  ||
         | |    (/    -)\
         | |    |`-'` |\`
      __/  |    | _/  |
     (___) \.  _.\__. `\___
     (___)  )\/  \    _/  ~\.
     (___) . \   `--  _   `\
      (__)-    ,/        (   |
           `--~|         |   |
               |         |   |
EOF
exit 0
