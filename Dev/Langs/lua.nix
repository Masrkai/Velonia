# Langs/lua.nix
# lua / luajit + common toolkit packages -> dev/registry.nix (editor tooling).
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    lua
    luarocks

    # LuaJIT wrapped with common packages and testing/linting tools
    (luajit.withPackages (ps: with ps; [
      penlight
      lua-cjson
      luasocket
      luafilesystem
      busted
      luacheck
    ]))
  ];
}
