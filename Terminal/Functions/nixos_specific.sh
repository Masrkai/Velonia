#NIXPKGS nix-output-monitor

garbage(){
    # Run operations sequentially with error handling
    echo "Collecting garbage..."
    sudo nix-collect-garbage -d || { echo "Garbage collection failed"; return 1; }

    echo "Optimizing store..."
    nix-store --optimise || { echo "Store optimization failed"; return 1; }

    # # Check if pip exists before trying to purge
    # if command -v pip &> /dev/null; then
    #     echo "Purging pip cache..."
    #     pip cache purge || echo "Warning: pip cache purge failed"
    # fi

    echo "Cleanup complete!"
}

gens(){
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
    echo ""
    echo "To remove generations, use:"
    echo "  sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations <Gen-Numbers>"
    echo "Or to keep only last N generations:"
    echo "  sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +N"
}

switch(){
    # Refresh sudo once upfront
    sudo -v || return 1

    # Use simpler command - sudo inherits the current shell
    sudo nixos-rebuild switch --show-trace 2>&1 | nom
}

update(){
    echo "Updating channels..."
    sudo nix-channel --update || { echo "Channel update failed"; return 1; }

    echo "Rebuilding system..."
    # No need for |& (which is bash-specific) - 2>&1 handles stderr
    sudo nixos-rebuild switch --upgrade --show-trace 2>&1 | nom
}

# Optional: add a rollback function
rollback(){
    sudo nixos-rebuild switch --rollback --show-trace 2>&1 | nom
}