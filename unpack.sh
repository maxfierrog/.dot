#!/bin/bash
# Symlink the contents of source_dir into target_dir.
#
# Most top-level items are linked directly. Directories listed in MERGE_DIRS
# are instead created as real directories in target_dir, and only their
# children are linked. This way, tools that write machine-specific state into
# them (caches, keys, credentials, logs) do not write into this repository.
#
# Existing files are never overwritten; conflicts are reported and skipped.

MERGE_DIRS=(.config .cargo .ssh)

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 source_dir target_dir"
    exit 1
fi

source_dir=$(realpath "$1")
target_dir=$(realpath "$2")

for dir in "$source_dir" "$target_dir"; do
    if [ ! -d "$dir" ]; then
        echo "Directory $dir does not exist."
        exit 1
    fi
done

is_merge_dir() {
    local name
    for name in "${MERGE_DIRS[@]}"; do
        [ "$1" = "$name" ] && return 0
    done
    return 1
}

link() {
    local src="$1" dst="$2"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        return
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        echo "Skipping $dst: already exists"
        return
    fi
    ln -s "$src" "$dst"
}

for item in "$source_dir"/* "$source_dir"/.[!.]* "$source_dir"/..?*; do
    [ -e "$item" ] || continue
    name=$(basename "$item")
    if [ -d "$item" ] && is_merge_dir "$name"; then
        dst="$target_dir/$name"
        if [ -L "$dst" ]; then
            echo "Skipping $dst: is a symlink (old layout?); convert it to a real directory"
            continue
        fi
        mkdir -p "$dst"
        [ "$name" = ".ssh" ] && chmod 700 "$dst"
        for child in "$item"/* "$item"/.[!.]* "$item"/..?*; do
            [ -e "$child" ] || continue
            link "$child" "$dst/$(basename "$child")"
        done
    else
        link "$item" "$target_dir/$name"
    fi
done

echo "Soft links created in $target_dir for all items in $source_dir."
