{ pkgs, ... }:
let
  zen-src = builtins.fetchGit {
    url = "https://github.com/youwen5/zen-browser-flake";
    ref = "master";
    rev = "36b24209358c82e0ea5404ba003ae8dc37334c86";
  };

  zen-browser-pkgs = import zen-src { inherit pkgs; };

  zen-browser = pkgs.wrapFirefox zen-browser-pkgs.zen-browser-unwrapped {
    pname = "zen-browser";
    extraPolicies = {
      ExtensionSettings = {
        # https://addons.mozilla.org/firefox/downloads/latest/<EXTENSION-URL-NAME>/latest.xpi
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };

        "gdpr@cavi.au.dk" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/consent-o-matic/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
         };

         "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/user-agent-string-switcher/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
         };
      };
    };
  };
in {
  environment.systemPackages = [ zen-browser ];
}