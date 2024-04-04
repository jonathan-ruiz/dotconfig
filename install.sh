#!/bin/bash

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Sync dotfiles to home directory using rsync
log "Syncing dotfiles to home directory..."
rsync -av --exclude={'provisioning.sh','install.sh'} ./ ~/
if [ $? -eq 0 ]; then
    log "Dotfiles synced successfully!"
else
    log "Error: Dotfiles sync failed."
    exit 1
fi

# Set zsh as default shell
log "Setting zsh as default shell..."
chsh -s "$(which zsh)"
if [ $? -eq 0 ]; then
    log "Zsh set as default shell successfully!"
else
    log "Error: Failed to set zsh as default shell."
    exit 1
fi

# Configure Docker if present
if command -v docker &> /dev/null; then
    log "Configuring Docker..."
    sudo systemctl start docker.service
    sudo systemctl enable docker.service
    sudo usermod -aG docker "$USER"
    if [ $? -eq 0 ]; then
        newgrp docker
        log "Docker configured successfully!"
    else
        log "Error: Failed to configure Docker."
        exit 1
    fi
else
    log "Docker not found, skipping configuration."
fi


if [ $? -ne 0 ]; then
    log "Error: Failed to activate group changes for Docker."
    exit 1
fi

# Install azure-cli through docker
log "Installing azure-cli (az)"
# Using alias for this breaks third party tools like sops, it use az but wont import the aliases
az_content="#!/bin/bash
docker run -v ~/.azure:/root/.azure -v /home/jruiz/.ssh:/root/.ssh mcr.microsoft.com/azure-cli az \"\$@\"
"
# Write the content to a file named 'az'
echo "$az_content" > /usr/bin/az
# Make the file executable
chmod +x /usr/bin/az

log "Installation completed successfully!"

