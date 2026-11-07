{ lib
, stdenvNoCC
, fetchFromGitHub
, makeWrapper
, bash
, coreutils
, findutils
, gnugrep
, python3
, pandoc
, typst
, mermaid-cli
, newcomputermodern
, dejavu_fonts
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mrkc";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "Masrkai";
    repo = "MRKcompile";
    rev = "v${finalAttrs.version}";
    hash =
      "sha256-FvG1OQm3j2F13Vx2xOqE+lY5E/3d7D5fBXzzz+5ZhY4=";
      # lib.fakeHash;
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash python3 ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Copy the whole compile/ directory so that every asset sitting next
    # to compile.sh (metadata.yaml, preamble.typ, processors, lua filter)
    # ends up beside it. The script finds them via BASH_SOURCE.
    install -d $out/share/mrkc
    cp -r compile/. $out/share/mrkc/
    chmod +x $out/share/mrkc/compile.sh $out/share/mrkc/*.py

    patchShebangs $out/share/mrkc

    makeWrapper $out/share/mrkc/compile.sh $out/bin/mrkc \
      --prefix PATH : ${lib.makeBinPath [
        coreutils findutils gnugrep
        python3 pandoc typst mermaid-cli
      ]} \
      --set-default TYPST_FONT_PATHS \
        "${newcomputermodern}/share/fonts:${dejavu_fonts}/share/fonts"

    runHook postInstall
  '';

  meta = {
    description = "Markdown to PDF pipeline (pandoc + Typst) with Mermaid, remote images and native tables";
    homepage = "https://github.com/Masrkai/MRKcompile";
    mainProgram = "mrkc";
    platforms = lib.platforms.linux;
  };
})
