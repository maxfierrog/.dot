#!/bin/bash
# Made by GPT-4o

# Check if exactly two arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 source_dir target_dir"
    exit 1
fi

source_dir=$(realpath "$1")
target_dir=$(realpath "$2")

# Check if source directory exists
if [ ! -d "$source_dir" ]; then
    echo "Source directory $source_dir does not exist."
    exit 1
fi

# Check if target directory exists
if [ ! -d "$target_dir" ]; then
    echo "Target directory $target_dir does not exist."
    exit 1
fi

# Create soft links for all files and directories from source_dir to target_dir
for item in "$source_dir"/* "$source_dir"/.*; do
    # Skip the special directories . and ..
    if [ "$item" != "$source_dir/." ] && [ "$item" != "$source_dir/.." ]; then
        ln -s "$item" "$target_dir"
    fi
done

echo "Soft links created in $target_dir for all items in $source_dir."

