{ config, lib, pkgs, modulesPath, ... }:

let
  customPackages = {
    proton-ge-bin = pkgs.callPackage ../Programs/Packages/proton-ge-bin.nix {};
  };
in
{

 environment.systemPackages = with pkgs; [
  heroic-unwrapped

  dxvk
  # vkd3d
  mangohud

  winetricks
  # wineWowPackages.stableFull

  #Games
  unciv
  openttd
  mindustry-wayland
];

  #> Steam
  programs.steam = {
    enable = true;
    extest.enable = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [ customPackages.proton-ge-bin dwproton-bin ];

    remotePlay.openFirewall = false;                # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false;           # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = false; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;


  # Link the Proton-GE nix store path to the user directory.
  # This is needed for using nixpkgs' proton-ge-bin with Heroic and others.
  #
  # Discussion: https://discourse.nixos.org/t/using-proton-ge-bin-package-outside-of-steam/77598/2
  systemd.user.tmpfiles =  {
    enable = true; # Let this fail, if someone changes the default.
    rules = let
      steaminstalldir = "%h/.local/share/Steam";
      compatdir = "${steaminstalldir}/compatibilitytools.d";
      link = "${compatdir}/Proton-GE";
      target = customPackages.proton-ge-bin.steamcompattool.outPath;
      steamdir = "%h/.steam";
    in [
      "d ${compatdir} - - - - -"
      "L+ ${link} - - - - ${target}"

      # When Steam gets started for the first time, it creates a directory with
      # symlinks to the install directory (among other things). Third party
      # tools are using these to find Proton versions.
      "d ${steamdir} - - - - -"
      "L ${steamdir}/root - - - - ${steaminstalldir}"
      "L ${steamdir}/steam - - - - ${steaminstalldir}"
    ];
  };

}
