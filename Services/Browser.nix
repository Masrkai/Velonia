{ pkgs, ... }:
let
  zen-src = builtins.fetchGit {
    url = "https://github.com/youwen5/zen-browser-flake";
    ref = "master";
    rev = "36b24209358c82e0ea5404ba003ae8dc37334c86";
  };

  zen-browser-pkgs = import zen-src { inherit pkgs; };
in {
  nixpkgs.config.zen.policies = {
    ExtensionSettings = {
      "uBlock0@raymondhill.net" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        installation_mode = "force_installed";
      };
    };
  };

  environment.systemPackages = [
    zen-browser-pkgs.zen-browser
  ];
}