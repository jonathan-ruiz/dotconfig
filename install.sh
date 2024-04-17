#!/bin/bash

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" 
}

# Error handling function
handle_error() {
    if [ $? -ne 0 ]; then
        log "${RED}Error: $1${NC}"
        exit 1
    fi
}

# ASCII art function
ascii_art() {
    cat << "EOF"
 ____                  _             
|  _ \  ___  ___ _ __ | |_ ___  _ __ 
| | | |/ _ \/ _ \ '_ \| __/ _ \| '__|
| |_| |  __/  __/ | | | || (_) | |   
|____/ \___|\___|_| |_|\__\___/|_|   
                                     
EOF
}

# Print ASCII art
ascii_art

# Call provisioning script and pass arguments
log "${GREEN}Running provisioning script...${NC}"
./home/.scripts/provisioning.sh "$@"

log "${GREEN}Provisioning script completed.${NC}"
# Sync dotfiles to home directory using rsync
log "${GREEN}Syncing dotfiles to home directory...${NC}"
rsync -av ./home/ ~/ && handle_error "Dotfiles sync failed"

log "${GREEN}Dotfiles synced successfully!${NC}"

# Sync etc files
log "${GREEN}Syncing etc/ files...${NC}"
sudo rsync -av etc/ /etc/ && handle_error "etc/ files sync failed"

log "${GREEN}etc/ files synced successfully!${NC}"

# Set zsh as default shell
log "${GREEN}Setting zsh as default shell...${NC}"
chsh -s "$(which zsh)"
chsh_exit_status=$?
if [ $chsh_exit_status -ne 0 ]; then
    log "${RED}Error: Failed to set zsh as default shell.${NC}"
    exit 1
fi

log "${GREEN}Zsh set as default shell successfully!${NC}"

# Configure Docker if present
if command -v docker &> /dev/null; then
    log "${GREEN}Configuring Docker...${NC}"
    sudo systemctl start docker.service && handle_error "Failed to start Docker service"
    sudo systemctl enable docker.service && handle_error "Failed to enable Docker service"
    sudo usermod -aG docker "$USER" && handle_error "Failed to add user to Docker group"
    newgrp docker
    log "${GREEN}Docker configured successfully!${NC}"
else
    log "${RED}Docker not found, skipping configuration.${NC}"
fi

# Install azure-cli through docker
log "${GREEN}Installing azure-cli (az)...${NC}"
az_content="#!/bin/bash
docker run -v ~/.azure:/root/.azure -v /home/jruiz/.ssh:/root/.ssh mcr.microsoft.com/azure-cli az \"\$@\"
"
# Write the content to a file named 'az'
echo "$az_content" | sudo tee /usr/local/bin/az >/dev/null
# Make the file executable
sudo chmod +x /usr/local/bin/az
handle_error "Failed to install azure-cli"

log "${GREEN}Installation completed successfully!${NC}"

