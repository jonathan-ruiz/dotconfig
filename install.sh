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
    local error_msg=$1
    local caller_name=$2
    log "${RED}Error in $caller_name: $error_msg${NC}"
    exit 1
}

# Check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Add an alias to .zshrc
add_alias_to_zshrc() {
    local alias_command=$1
    if ! grep -qF "$alias_command" ~/.zshrc; then
        echo "$alias_command" >> ~/.zshrc
        echo "Alias added to .zshrc"
    else
        echo "Alias already exists in .zshrc"
    fi
}

# Print ASCII art
cat << "EOF"


 _____          _        _ _ 
|_   _|        | |      | | |
  | | _ __  ___| |_ __ _| | |
  | || '_ \/ __| __/ _` | | |
 _| || | | \__ \ || (_| | | |
 \___/_| |_|___/\__\__,_|_|_|
                             
                             

                                     
EOF

# Call provisioning script and pass arguments
log "${GREEN}Running provisioning script...${NC}"
#./home/.scripts/provisioning.sh "$@" || handle_error "Provisioning script failed" "main"

log "${GREEN}Provisioning script completed.${NC}"

# Sync dotfiles to home directory using rsync
log "${GREEN}Syncing dotfiles to home directory...${NC}"
#rsync -av ./home/ ~/ || handle_error "Dotfiles sync failed" "main"
log "${GREEN}Dotfiles synced successfully!${NC}"

# Sync etc files
log "${GREEN}Syncing etc/ files...${NC}"
#sudo rsync -av etc/ /etc/ || handle_error "etc/ files sync failed" "main"
log "${GREEN}etc/ files synced successfully!${NC}"

# Set zsh as default shell
log "${GREEN}Setting zsh as default shell...${NC}"
#chsh -s "$(command -v zsh)" || handle_error "Failed to set zsh as default shell" "main"
log "${GREEN}Zsh set as default shell successfully!${NC}"

# Configure Docker if present
if command_exists docker; then
    log "${GREEN}Configuring Docker...${NC}"
    sudo systemctl start docker.service || handle_error "Failed to start Docker service" "main"
    sudo systemctl enable docker.service || handle_error "Failed to enable Docker service" "main"
    sudo usermod -aG docker "$USER" || handle_error "Failed to add user to Docker group" "main"
    
    # Prompt for password before executing newgrp
    echo "Please enter your password for Docker group membership:"
    #sudo newgrp docker || handle_error "Failed to switch to Docker group" "main"
    
    log "${GREEN}Docker configured successfully!${NC}"
else
    log "${RED}Docker not found, skipping configuration.${NC}"
fi


echo "Alias"
# Add aliases to .zshrc
add_alias_to_zshrc "alias plasticgui='docker run --privileged --network host --rm -it -v \$HOME/Projects:/root/Projects -v ~/.plastic4:/root/.plastic4 -v /tmp/.X11-unix:/tmp/.X11-unix -e XAUTH_TOKEN=\"\$(xauth list)\" -e DISPLAY=:0 jonathanruiz3/plasticscm-client sh -c \"xauth add \$XAUTH_TOKEN && plasticgui\"'"
add_alias_to_zshrc "alias icat=\"kitten icat\""
add_alias_to_zshrc "alias ls=lsd"
add_alias_to_zshrc "alias ssh='kitty +kitten ssh'"

# Install azure-cli through docker
log "${GREEN}Installing azure-cli (az)...${NC}"
az_content="#!/bin/bash
docker run -v ~/.azure:/root/.azure -v $HOME/.ssh:/root/.ssh mcr.microsoft.com/azure-cli az \"\$@\"
"
# Write the content to a file named 'az'
echo "$az_content" | sudo tee /usr/local/bin/az >/dev/null
# Make the file executable
sudo chmod +x /usr/local/bin/az

log "${GREEN}Installation completed successfully!${NC}"

