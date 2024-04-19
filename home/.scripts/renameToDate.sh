#!/bin/bash

# Function to rename images using exiftool
rename_images() {
    exiftool -d %Y-%m-%d_%H%M%S%%c.%%e "-FileName<$1" "$2" -r
}

# Main script
directory="$1"

# Get the list of files before renaming
before_rename=$(find "$directory" -type f)

# Try renaming using CreateDate
echo "Renaming images using CreateDate..."
rename_images CreateDate "$directory"

# Get the list of files after renaming
after_rename=$(find "$directory" -type f)

# Check which files were not renamed
unrenamed_files=$(comm -23 <(echo "$before_rename" | sort) <(echo "$after_rename" | sort))

if [ -n "$unrenamed_files" ]; then
    echo "Some files could not be renamed using CreateDate. Trying fallback options..."
    
    # Try renaming using ProfileDateTime
    echo "Renaming images using ProfileDateTime..."
    rename_images ProfileDateTime "$directory"
    
    # Get the list of files after renaming with ProfileDateTime
    after_profile_date_time=$(find "$directory" -type f)
    
    # Check which files were not renamed using ProfileDateTime
    unrenamed_files=$(comm -23 <(echo "$after_rename" | sort) <(echo "$after_profile_date_time" | sort))
    
    if [ -n "$unrenamed_files" ]; then
        # Try renaming using DateTimeOriginal
        echo "Renaming images using DateTimeOriginal..."
        rename_images DateTimeOriginal "$directory"
    fi
fi

echo "Renaming complete."

