# vera.nix
{ lib
, rustPlatform
, fetchFromGitHub
, makeDesktopItem
, copyDesktopItems
, makeWrapper
, autoPatchelfHook
, pkg-config
, fontconfig
, freetype
, expat
, wayland
, libxkbcommon
, libGL
, stdenv
, zenity
}:

let

  runtimeLibs = [
    fontconfig
    freetype
    expat
    wayland
    libxkbcommon
    libGL
    stdenv.cc.cc.lib
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "vera";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "Masrkai";
    repo  = "Vera";
    tag   = version;
    hash  = "sha256-mv6KfUPL6/t50sPn5ZEmv9zMtETRUA8ei8HGKt1M18Q="; # replace after first build attempt
  };

  cargoHash = "sha256-nRqhWyrRoHn0Lg3ba+RYZO2gRpY6iyzhOO+XM2bWU8g="; # replace after first build attempt

  nativeBuildInputs = [
    copyDesktopItems
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;

  desktopItems = [
    (makeDesktopItem {
      name        = "vera";
      desktopName = "Vera";
      exec        = "vera %F";
      icon        = "vera";
      comment     = "Image metadata viewer";
      categories  = [ "Graphics" "Viewer" ];
      mimeTypes   = [ "image/jpeg" "image/png" "image/tiff" "image/bmp" ];
      terminal    = false;
    })
  ];

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp ${src}/assets/Vera.svg $out/share/icons/hicolor/scalable/apps/vera.svg

    wrapProgram $out/bin/vera \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
      --prefix PATH : ${lib.makeBinPath [ zenity ]}
  '';

  meta = {
    description = "Image metadata viewer";
    license     = lib.licenses.mit;
    platforms   = lib.platforms.linux;
  };
}