{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  bash,
  coreutils,
  gawk,
  gnugrep,
  curl,
  pandoc,
  typst,
  mermaid-cli,
  newcomputermodern,
  dejavu_fonts,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mrkc";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "Masrkai";
    repo = "MRKcompile";
    rev = "v${finalAttrs.version}";
    hash =
      "sha256-JxSqktIW/ZFzbgDCgsumkWpZmgY7HGUH4K/HJvl1IJQ=";
      # lib.fakeHash;
  };

  nativeBuildInputs = [makeWrapper];
  buildInputs = [bash];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # compile.sh finds metadata.yaml, preamble.typ, typst_template.typ,
    # the *_processor.sh scripts and the Lua filters next to itself.
    install -d $out/share/mrkc
    cp -r compile/. $out/share/mrkc/
    chmod +x $out/share/mrkc/compile.sh $out/share/mrkc/*_processor.sh

    patchShebangs $out/share/mrkc

    makeWrapper $out/share/mrkc/compile.sh $out/bin/mrkc \
      --prefix PATH : ${lib.makeBinPath [
      coreutils
      gawk
      gnugrep
      curl
      pandoc
      typst
      mermaid-cli
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
