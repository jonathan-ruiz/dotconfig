#!/bin/bash

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> script.log
}

# Sync dotfiles to home directory using rsync
log "Syncing dotfiles to home directory..."
rsync -av --exclude='*' --include={'.fonts', '.icons', '.config', '.scripts', '.gitconfig', '.profile', '.zshrc', '.p10k.zsh'} ./ ~/

# Sync etc files
log "Syncing etc/ files..."
rsync -av etc/ /etc/

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

# Install azure-cli through docker
log "Installing azure-cli (az)"
az_content="#!/bin/bash
docker run -v ~/.azure:/root/.azure -v /home/jruiz/.ssh:/root/.ssh mcr.microsoft.com/azure-cli az \"\$@\"
"
# Write the content to a file named 'az'
echo "$az_content" > /usr/local/bin/az
# Make the file executable
chmod +x /usr/local/bin/az

if [ $? -eq 0 ]; then
    log "Installation completed successfully!"
else
    log "Error: Failed to install azure-cli."
    exit 1
fi


