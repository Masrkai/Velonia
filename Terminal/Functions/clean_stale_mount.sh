clean_stale_mount() {
    local mount_name="$1"
    local user="${2:-$USER}"
    local mount_path="/run/media/$user/$mount_name"
    if [ -z "$mount_name" ]; then
        echo "Error: Please provide a mount name"
        echo "Usage: clean_stale_mount <mount_name> [username]"
        return 1
    fi
    echo "Cleaning stale mount: $mount_path"
    sudo umount "$mount_path" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo " Unmounted $mount_path"
    else
        echo "Nothing to unmount (not mounted or already unmounted)"
    fi
    if [ -d "$mount_path" ]; then
        sudo rm -rf "$mount_path"
        if [ $? -eq 0 ]; then
            echo "Removed stale directory $mount_path"
            echo "Done! You can now reconnect your drive."
        else
            echo "Failed to remove directory"
            return 1
        fi
    else
        echo "Directory doesn't exist (already cleaned)"
    fi
}

_clean_stale_mount_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "$COMP_CWORD" in
        1)
            # First arg: mount names from /run/media/$USER/
            local mounts=()
            if [ -d "/run/media/$USER" ]; then
                mounts=( $(ls "/run/media/$USER" 2>/dev/null) )
            fi
            COMPREPLY=( $(compgen -W "${mounts[*]}" -- "$cur") )
            ;;
        2)
            # Second arg: usernames that have a /run/media/<user> directory
            local users=()
            if [ -d "/run/media" ]; then
                users=( $(ls "/run/media" 2>/dev/null) )
            fi
            COMPREPLY=( $(compgen -W "${users[*]}" -- "$cur") )
            ;;
    esac
}

complete -F _clean_stale_mount_completion clean_stale_mount
