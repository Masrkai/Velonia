{ pkgs, ... }:

{

  # Set regulatory domain
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=US
    options rtw89_pci disable_aspm_l1=y disable_aspm_l1ss=y disable_clkreq=y
    options rtw89_core disable_ps_mode=y
  '';

  hardware = {
      wirelessRegulatoryDatabase = true;
      firmware = with pkgs; [
      wireless-regdb
      linux-firmware
      ];
    };

}