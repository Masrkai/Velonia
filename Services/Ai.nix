{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  secrets = import ../Sec/secrets.nix;
  unstable = import <unstable> { config.allowUnfree = true; };
in
{
  services.ollama = {
    enable = true;
    package = unstable.ollama-cuda;

    port = 11434;
    host = "127.0.0.1";

    user = "ollama";
    group = "ollama";

    environmentVariables = {
      OLLAMA_MODELS = "/home/masrkai/AI";
    };
  };

  services.open-webui = {
    enable = false;
    # stateDir = "/var/lib/open-webui";

    package =
      #pkgs.open-webui;
      #unstable.open-webui;
      pkgs.callPackage ../Programs/python-libs/open-webui.nix { };

    port = 8080;
    host = "127.0.0.1";
    openFirewall = true;
    environment = {
      TZ = secrets.TZ;
      WEBUI_AUTH = "False";
      DATA_DIR = "/var/lib/open-webui/data"; # Explicitly set data directory
      OLLAMA_BASE_URL = "http://127.0.0.1:11434"; # Redundant but sometimes helps
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";

      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      ANONYMIZED_TELEMETRY = "False";
      WEBUI_SESSION_COOKIE_SECURE = "True";
      WEBUI_SESSION_COOKIE_SAME_SITE = "strict";

      #! NONSENSE IN MY HUMBLE OPINION
      ENABLE_OPENAI_API = "False";
      ENABLE_MESSAGE_RATING = "False";
      ENABLE_EVALUATION_ARENA_MODELS = "False";
      ENABLE_AUTOCOMPLETE_GENERATION = "False";
    };

  };

  services.tika = {
    enable = false;
    enableOcr = true;

    port = 9998;
    openFirewall = false;
    listenAddress = "127.0.0.1";
  };

  virtualisation = lib.mkMerge [
    {
      podman = {
        enable = false;
        dockerCompat = true;
        #defaultNetwork.settings.dns_enabled = true;
      };

      # oci-containers = {
      #   backend = "podman";
      #   containers = {
      #     "open-webui" = import ./containers/open-webui.nix;
      #   };
      # };
    }
  ];

  environment.systemPackages = with pkgs; [
    unstable.opencode
    # unstable.graphify
  ];

}
