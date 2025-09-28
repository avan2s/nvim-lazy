#!/bin/bash

# A script to remove the data, state, and cache directories for a specific
# Neovim distribution.
#
# Usage:
# ./clean-nvim-dist.sh <distribution_name>
#
# Example:
# ./clean-nvim-dist.sh lazyvim

# --- Validation ---
# Check if the distribution name parameter is provided.
# The -z check verifies if the string is null or empty.
if [ -z "$1" ]; then
  echo "Error: Neovim distribution name is required." >&2
  echo "Usage: $0 <distribution_name>" >&2
  exit 1
fi

# Store the distribution name from the first parameter in a variable.
distname="$1"

echo "Starting cleanup for Neovim distribution: '$distname'"
echo "---"

# --- Define Target Directories ---
# Define paths in an array for easy iteration. Using $HOME is more robust in scripts.
declare -a target_dirs=(
  "$HOME/.local/share/nvim-$distname"
  "$HOME/.local/state/nvim-$distname"
  "$HOME/.cache/nvim-$distname"
)

# --- Removal Logic ---
# Loop through the defined directories and remove them if they exist.
for dir in "${target_dirs[@]}"; do
  if [ -d "$dir" ]; then
    echo "Removing: $dir"
    # The -R flag is for recursive deletion, -f is to force and ignore errors
    # if the file doesn't exist (though we already checked).
    rm -Rf "$dir"
  else
    echo "Skipping (not found): $dir"
  fi
done

echo "---"
echo "Cleanup for '$distname' complete."
