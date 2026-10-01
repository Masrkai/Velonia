{ lib, stdenv, fetchzip, autoPatchelfHook, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "whisper-cpp";
  version = "1.8.3";

  src = fetchzip {
    url = "https://github.com/ggml-org/whisper.cpp/releases/download/v${version}/whisper-bin-x64.zip";
    hash = "sha256-N9EQoG/oQ0HsHKTMcI8VHG2Scqg3MLSO4hth6OugsHw=";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin
    cp -r * $out/bin/
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Port of OpenAI's Whisper model in C/C++ (pre-compiled binaries)";
    homepage = "https://github.com/ggerganov/whisper.cpp";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "whisper-cli";
  };
}