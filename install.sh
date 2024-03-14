#!/bin/bash

# Sync dotfiles to home directory using rsync
echo "Syncing dotfiles to home directory..."
rsync -av --exclude={'provisioning.sh','install.sh'} ./ ~/ 

echo "Setting zsh as default..."
chsh -s $(which zsh)

echo "Dotfiles synced successfully!"

