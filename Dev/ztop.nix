{pkgs, ...}:

{
  imports = [
    # ./cpp_env.nix

    ./git.nix
    ./nix-ld.nix

    ./Langs/ztop.nix
    ./Domain_Specific/ztop.nix

    ./IDEs/nvim.nix
    ./IDEs/vscodium.nix
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

    zed-editor-fhs

    typos
    typos-lsp
  ];


}
