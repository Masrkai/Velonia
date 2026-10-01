{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    sqlite
    sqlitebrowser

    turso
    turso-cli

    arrow-cpp
    arrow-glib

    jq

  ];

}