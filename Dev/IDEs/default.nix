# IDEs/default.nix
#
# Declares which editors are enabled, DRIVEN BY ID.nix hardware flags.
#
#   ThinkPad          -> neovim only
#   every other model -> neovim + VSCodium
#
# Everything is set with mkDefault so you can override per machine:
#   dev.editors.vscodium.enable = true;
#
# NOTE: hardware.isXxx comes from a generated file that ID.nix imports, so it
# can only be read through `config`. Never use it inside `imports = [ ... ]`
# (that causes infinite recursion). That is why both editor modules are always
# imported and gated with mkIf instead.
{
  lib,
  config,
  ...
}: {
  imports = [
    ../../ID/ID.nix # NOT negotiable: hardware flags + identity live here
    ./nvim.nix
    ./vscodium.nix
  ];

  options.dev.editors = {
    neovim.enable = lib.mkEnableOption "neovim (nixvim)";
    vscodium.enable = lib.mkEnableOption "VSCodium with the shared tooling";
  };

  config = {
    # Neovim is the universal terminal fallback: on everywhere.
    dev.editors.neovim.enable = lib.mkDefault true;

    # VSCodium everywhere except the ThinkPad.
    dev.editors.vscodium.enable =
      lib.mkDefault true;
      # lib.mkDefault (!config.hardware.isThinkPad);

    # Fail loudly rather than silently giving a machine no IDE.
    assertions = [
      {
        assertion = config.dev.editors.neovim.enable || config.dev.editors.vscodium.enable;
        message = "dev.editors: at least one of neovim/vscodium must be enabled.";
      }
    ];
  };
}
