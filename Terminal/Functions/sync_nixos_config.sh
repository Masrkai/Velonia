# NixOS Configuration Sync Function
# Syncs /etc/nixos to ~/Programs/System/Nix_Configuration/
# Excludes /Sec folder and mirrors deletions/renames
# Protects git metadata and respects permissions
sync_nixos_config() {
    local source="/etc/nixos/"
    local dest="$HOME/Programs/Nix_Configuration/"
    local exclude_dir="Sec"

    # Validate source exists
    if [[ ! -d "$source" ]]; then
        echo "Error: Source directory $source does not exist" >&2
        return 1
    fi

    # Create destination if it doesn't exist
    if [[ ! -d "$dest" ]]; then
        echo "Creating destination directory: $dest"
        mkdir -p "$dest" || {
            echo "Error: Failed to create destination directory" >&2
            return 1
        }
    fi

    # Check if we have read permissions for source
    if [[ ! -r "$source" ]]; then
        echo "Error: No read permission for $source. You may need sudo." >&2
        return 1
    fi

    echo "Syncing NixOS configuration..."
    echo "Source: $source"
    echo "Destination: $dest"
    echo "Excluding: $exclude_dir/"
    echo ""

    # Use rsync for robust syncing with deletions
    # -a: archive mode (preserves permissions, timestamps, etc.)
    # -v: verbose
    # --delete: delete files in dest that don't exist in source
    # --exclude: exclude specific directories/files
    # --progress: show progress
    # --human-readable: human-readable output
    # --filter: protect git and repo files from deletion
    # --no-perms: do not preserve permissions (avoid root ownership issues)
    # --no-owner: do not preserve owner (avoid root ownership issues)
    # --no-group: do not preserve group (avoid root ownership issues)
    if command -v rsync &> /dev/null; then
        rsync -av \
            --delete \
            --exclude="/$exclude_dir" \
            --exclude="/$exclude_dir/" \
            --filter='protect .git***' \
            --filter='protect .gitignore' \
            --filter='protect .gitattributes' \
            --filter='protect README*' \
            --filter='protect LICENSE*' \
            --filter='protect *.md' \
            --no-perms \
            --no-owner \
            --no-group \
            --progress \
            --human-readable \
            "$source" "$dest" || {
                echo "Error: rsync failed with exit code $?" >&2
                return 1
            }
    else
        echo "Warning: rsync not found, falling back to manual sync" >&2
        echo "Install rsync for better performance: nix-env -iA nixos.rsync" >&2

        # Fallback: manual copy with find
        # First, copy/update files
        find "$source" -type f -o -type l | while IFS= read -r file; do
            # Skip if file is in excluded directory
            if [[ "$file" == *"/$exclude_dir/"* ]]; then
                continue
            fi
            # Get relative path
            rel_path="${file#$source}"
            dest_file="$dest$rel_path"
            dest_dir=$(dirname "$dest_file")
            # Create destination directory if needed
            mkdir -p "$dest_dir" || continue
            # Copy file if newer or doesn't exist
            if [[ ! -e "$dest_file" ]] || [[ "$file" -nt "$dest_file" ]]; then
                cp -p "$file" "$dest_file" && echo "Copied: $rel_path"
            fi
        done

        # Second, remove files that no longer exist in source
        find "$dest" -type f -o -type l | while IFS= read -r file; do
            rel_path="${file#$dest}"
            source_file="$source$rel_path"
            # Remove if doesn't exist in source (and not in excluded dir)
            if [[ ! -e "$source_file" ]] && [[ "$rel_path" != *"/$exclude_dir/"* ]]; then
                # Skip git files and other protected files
                if [[ "$rel_path" != .git* ]] && \
                   [[ "$rel_path" != .gitignore ]] && \
                   [[ "$rel_path" != .gitattributes ]] && \
                   [[ "$rel_path" != README* ]] && \
                   [[ "$rel_path" != LICENSE* ]] && \
                   [[ "$rel_path" != *.md ]]; then
                    rm "$file" && echo "Removed: $rel_path"
                fi
            fi
        done

        # Third, remove empty directories
        find "$dest" -type d -empty -delete
    fi

    echo ""
    echo "Sync completed successfully!"
    return 0
}
