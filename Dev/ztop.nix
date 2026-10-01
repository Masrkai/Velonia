{ pkgs, ... }:

{
  imports = [
    ./git.nix
    ./nix-ld.nix

    ./Langs/ztop.nix
    ./Specialized/ztop.nix

    # Declares dev.editors.* and imports nvim.nix + vscodium.nix.
    # Which editors turn on is decided by ID.nix hardware flags, not by
    # commenting lines in/out here.
    ./IDEs/default.nix
  ];

  #--> direnv
  programs.direnv = {
    enable = true;
    loadInNixShell = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gource
    glslang
  ];
  # typos / typos-lsp moved to dev/registry.nix (VSCodium points at typos-lsp).
}
