#!/bin/bash

# Colors for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${GREEN}[INFO]${NC} $@"
}

error() {
    echo -e "${RED}[ERROR]${NC} $@"
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    error "Usage: $0 <directory> <accuracy_percentage>"
    exit 1
fi

directory="$1"
accuracy="$2"

# Create images fingerprints database
log "Creating image fingerprints database..."
findimagedupes --recurse --fingerprints=./fingerprints.db --no-compare  "$directory" || { error "Failed to create fingerprints database."; exit 1; }

# Creates a collection with duplicates for inspection
log "Creating collection of duplicates for inspection..."
findimagedupes --recurse --fingerprints=./fingerprints.db --prune --threshold=$accuracy --collection=./duplicates "$directory" || { error "Failed to create collection of duplicates."; exit 1; }

# Prompt for confirmation to continue
echo -e "${YELLOW}Please inspect the collection of duplicates at .duplicates directory.${NC}"
read -p "Press [Enter] to continue..."

# Find duplicates and add .TODELETE suffix 
log "Finding duplicates and adding .TODELETE suffix..."
findimagedupes --recurse --fingerprints=./fingerprints.db --prune --threshold=$accuracy --include-file=./add_sufix.sh "$directory" > ./log.txt || { error "Failed to find duplicates and add suffix."; exit 1; }

# Delete files with TODELETE suffix
log "Deleting files with .TODELETE suffix..."
find "$directory" -name "*.TODELETE" -delete || { error "Failed to delete files with .TODELETE suffix."; exit 1; }

log "Script completed successfully."

