{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "lmstudio";
  version = "0.3.8";
  rev = "4";

  src = fetchurl {
    url = "https://installers.lmstudio.ai/linux/x64/${version}-${rev}/LM-Studio-${version}-${rev}-x64.AppImage";
    hash = "sha256-JnuEYU+vitBGS0WZdcleVW1DfZ+MonXz6U+ObUlsePM=";
  };

  # icon = fetchurl {
  #   url = "https://avatars.githubusercontent.com/u/133744619?s=280&v=4";
  #   hash = "sha256-DNRimhNFt6jLdjqv7o2cNz38K6XnevxD0rGymym3xBs=";
  # };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit
    pname
    version
    src
    ;

  extraPkgs = pkgs: [ pkgs.ocl-icd ];

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp -r ${appimageContents}/usr/share/icons $out/share
    install -m 444 -D ${appimageContents}/lm-studio.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/lm-studio.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=lmstudio'

  '';
    # install -Dm444 ${icon} $out/share/icons/hicolor/scalable/apps/${pname}.svg

  meta = {
      description = "LM Studio is an easy to use desktop app for experimenting with local and open-source Large Language Models (LLMs)";
      homepage = "https://lmstudio.ai/";
      license = lib.licenses.unfree;
      mainProgram = "lmstudio";
      maintainers = with lib.maintainers; [ offline ];
      platforms = [ "x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
}