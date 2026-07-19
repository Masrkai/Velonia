{ pkgs, lib, ... }:


{

  services.cloudflare-warp = {
    enable = true;
  };

  #? testing this you can run
  #> curl https://cloudflare.com/cdn-cgi/trace

}