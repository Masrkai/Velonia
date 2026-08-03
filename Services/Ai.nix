{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;

    port = 11434;
    host = "127.0.0.1";

    user = "ollama";
    group = "ollama";

    environmentVariables = {
      OLLAMA_MODELS = "/home/${config.identity.username}/AI";
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
      TZ = config.identity.secrets.TZ;
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

  environment.systemPackages = with pkgs; [

    litellm

    opencode
    pi-coding-agent

  ];



  services.litellm = {
    enable = false;

    host = "127.0.0.1"; # Bind to localhost for security
    port = 4000;

    # 1. Securely load your NVIDIA API key from an environment file
    environmentFile = "/etc/nixos/Sec/litellm.env";

    # 2. Define the LiteLLM proxy configuration
    settings = {
      model_list = [
        {
          # This is the "fake" model name OpenCode will request
          model_name = "nvidia-glm-5.2";
          litellm_params = {
            # Prefix with nvidia_nim/ to route to the NVIDIA provider [[38]]
            model = "nvidia_nim/nvidia/z-ai-glm-5.2"; 
            api_key = "os.environ/NVIDIA_API_KEY";
            
            # --- THE MAGIC: Retries & Backoff ---
            num_retries = 5;       # Retry up to 5 times on 429/ResourceExhausted errors
            timeout = 120;         # Wait up to 120s before giving up
            retry_after = 10;      # Base wait time (LiteLLM applies exponential backoff automatically)
          };
        }


        {
          # This is the "fake" model name OpenCode will request
          model_name = "nvidia-deepseek-v4-pro";
          litellm_params = {
            # Prefix with nvidia_nim/ to route to the NVIDIA provider [[38]]
            model = "nvidia_nim/nvidia/deepseek-ai-deepseek-v4-pro"; 
            api_key = "os.environ/NVIDIA_API_KEY";
            
            # --- THE MAGIC: Retries & Backoff ---
            num_retries = 5;       # Retry up to 5 times on 429/ResourceExhausted errors
            timeout = 120;         # Wait up to 120s before giving up
            retry_after = 10;      # Base wait time (LiteLLM applies exponential backoff automatically)
          };
        }

    
        
      ];

      # 3. Define the fallback chain
      router_settings = {
        # If "nvidia-proxy" exhausts its 5 retries, switch to "local-fallback" [[24]]
      };
    };
  };

  # Optional: Open the firewall if you need to access the proxy from other machines
  # networking.firewall.allowedTCPPorts = [ 4000 ];

}
