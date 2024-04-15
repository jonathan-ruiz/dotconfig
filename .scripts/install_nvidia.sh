#!/bin/bash

# Function to determine the NVIDIA driver package based on the detected graphics card
detect_nvidia_driver() {
    local gpu_info=$(lspci -k | grep -A 2 -E "(VGA|3D)")
    local code_name=$(echo "$gpu_info" | grep -oP 'VGA compatible controller: NVIDIA Corporation \K.*')

    if [[ -n "$code_name" ]]; then
        case "$code_name" in
            GA*|TU*) echo "nvidia" ;;
            *) echo "Unsupported driver" ;;
        esac
    else
        echo "No NVIDIA graphics card detected."
        exit 1
    fi
}

# Install NVIDIA driver based on the detected graphics card
install_nvidia_driver() {
    local driver_package=$(detect_nvidia_driver)
    
    if [[ "$driver_package" == "Unsupported driver" ]]; then
        echo "Unsupported graphics card detected."
        exit 1
    fi

    sudo pacman -S --needed $driver_package
}

# Main script
main() {
    # Check if lspci is installed
    if ! command -v lspci &> /dev/null; then
        echo "lspci command not found. Please install it."
        exit 1
    fi

    # Install NVIDIA driver
    install_nvidia_driver

    # Optional: Install 32-bit application support
    sudo pacman -S --needed lib32-$driver_package-utils

    # Optional: Modify /etc/mkinitcpio.conf to remove kms from HOOKS array
    # sed -i 's/\<kms\>//g' /etc/mkinitcpio.conf
    # sudo mkinitcpio -p linux

    echo "NVIDIA driver installation completed."
    echo "Please reboot your system for the changes to take effect."
}

# Execute the main function
main

