{ lib, pkgs, config, ... }:
let
  isThinkPad = config.hardware.isThinkPad;

  zen-src = builtins.fetchGit {
    url = "https://github.com/youwen5/zen-browser-flake";
    ref = "master";
    rev = "3ad1221d8d1157bd2b129c579b65b553b8419a0e";
  };

  zen-browser-pkgs = import zen-src { inherit pkgs; };

  zen-browser = pkgs.wrapFirefox zen-browser-pkgs.zen-browser-unwrapped {
    pname = "zen-browser";
    extraPolicies = {
      ExtensionSettings = {
        # https://addons.mozilla.org/firefox/downloads/latest/<EXTENSION-URL-NAME>/latest.xpi
        # https://addons.mozilla.org/en-US/firefox/addon/keepassxc-browser/ for example it's EXTENSION-URL-NAME = keepassxc-browser
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };

        "{74145f27-f039-47ce-a470-a662b129930a}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };

        "gdpr@cavi.au.dk" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/consent-o-matic/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
         };

         "keepassxc-browser@keepassxc.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = false;
         };

         "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/user-agent-string-switcher/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
         };

         "{6c00218c-707a-4977-84cf-36df1cef310f}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/port-authority/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
         };
      };
    };
  };
in {
    config = lib.mkMerge [
    # ThinkPad -> Zen
    (lib.mkIf isThinkPad {
      environment.systemPackages = [ zen-browser pkgs.brave ];
      environment.sessionVariables.BROWSER = "zen";
    })

    # Everything else -> Brave
    (lib.mkIf (!isThinkPad) {
      environment.systemPackages = [ pkgs.brave ];
      environment.sessionVariables.BROWSER = "brave";
    })
  ];
}
