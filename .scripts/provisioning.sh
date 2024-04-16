#!/bin/bash

# Function to print messages in different colors
print_message() {
    local color=$1
    local message=$2
    echo -e "\e[${color}m${message}\e[0m"
}

# Function to check if a file exists
check_file_exists() {
    local file=$1
    if [ ! -f "$file" ]; then
        print_message "1;31" "Error: $file not found. Please create it with package definitions."
        exit 1
    fi
}

# Function to install pacman packages
install_pacman_packages() {
    local packages=("$@")
    for pkg in "${packages[@]}"; do
        if pacman -Q "$pkg" &>/dev/null; then
            print_message "1;33" "$pkg is already installed."
        else
            sudo pacman -Sy --noconfirm --needed "$pkg" || {
                print_message "1;31" "Error: Failed to install $pkg."
                exit 1
            }
        fi
    done
}

# Function to install AUR packages
install_aur_packages() {
    local packages=("$@")
    for pkg in "${packages[@]}"; do
        if pacman -Qq "$pkg" &>/dev/null; then
            print_message "1;33" "$pkg is already installed. Skipping..."
        else
            print_message "1;32" "Installing $pkg AUR package..."
            trap 'cleanup' EXIT
            git clone https://aur.archlinux.org/"$pkg".git
            cd "$pkg" || continue
            makepkg -si --noconfirm || {
                print_message "1;31" "Error: Failed to install $pkg."
                exit 1
            }
            print_message "1;32" "Installation of $pkg completed successfully."
        fi
    done
}

# Function to prompt user for package installation
prompt_installation() {
    local title=$1
    local type=$2
    local packages=($3)
    print_message "1;34" "$title"
    if [ "$auto_confirm" = true ]; then
        choice='y'
    else
        read -p "Do you want to install these packages? (y/n): " choice
    fi

    case "$choice" in
        y|Y ) if [ "$type" = "pacman" ]; then
                  install_pacman_packages "${packages[@]}"
              elif [ "$type" = "aur" ]; then
                  install_aur_packages "${packages[@]}"
              else
                  print_message "1;31" "Invalid package type. No packages will be installed."
              fi
        ;;
        n|N ) print_message "1;32" "No packages will be installed.";;
        * ) print_message "1;31" "Invalid choice. No packages will be installed.";;
    esac
}

# Function to clean up temporary directories
cleanup() {
    if [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
        print_message "1;33" "Cleanup: Temporary directory '$temp_dir' removed."
    fi
}

# Main script starts here
print_message "" "Welcome to the Dotfiles Provisioning Script!"
print_message "" "This script will install necessary packages and configure powerlevel10k."
print_message "" "Please ensure you have sudo privileges and run this script as a normal user."

# Check if the script is run as root
[ "$(id -u)" -eq 0 ] && {
    print_message "1;31" "Error: This script should not be run as root. Please execute it as a normal user with sudo privileges."
    exit 1
}

# Check if the OS is Arch or Arch-based
command -v pacman &> /dev/null || {
    print_message "1;31" "Error: This script is designed for Arch Linux or Arch-based distributions."
    exit 1
}

# Check if packages.conf file exists
check_file_exists "packages.conf"

# Source the packages configuration file
source packages.conf

# Check if the script was run with the '-y' or '--yes' option
auto_confirm=false
[[ $1 == '-y' || $1 == '--yes' ]] && auto_confirm=true

# Loop over the associative array and install packages

for key in "${!packages[@]}"; do
    IFS=',' read -r name type package_list <<< "${packages[$key]}"
    IFS=' ' prompt_installation "$name" "$type" "${package_list[@]}"
done


# Install and configure powerlevel10k
if [ -f ~/.p10k.zsh ]; then
    print_message "1;33" "Powerlevel10k is already installed. Skipping installation."
else
    print_message "1;32" "Installing and configuring powerlevel10k..."
    sudo pacman -R --noconfirm zsh-theme-powerlevel10k
    yay -S --noconfirm zsh-theme-powerlevel10k-git
    echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
    print_message "1;32" "Powerlevel10k installed and configured."
fi

print_message "1;32" "Packages installed successfully!"
