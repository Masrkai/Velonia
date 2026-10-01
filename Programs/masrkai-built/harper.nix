{
  lib,
  rustPlatform,
  clang,
  libbpf,
  linuxHeaders,
  harperSrc ? null,
  ...
}: let
  defaultSrc = builtins.fetchGit {
    url = "https://github.com/Masrkai/Harper";
    ref = "refs/tags/v0.1.3"; # adjust to your actual tag name
  };
  finalSrc =
    if harperSrc == null
    then defaultSrc
    else harperSrc;
in
  rustPlatform.buildRustPackage {
    pname = "harper";
    version = "0.1.3";

    src = finalSrc;
    cargoLock.lockFile = "${finalSrc}/Cargo.lock";

    nativeBuildInputs = [clang];
    buildInputs = [libbpf linuxHeaders];

    hardeningDisable = ["all"];

    env = {
      LIBBPF_INCLUDE = "${libbpf}/include";
      KERNEL_INCLUDE = "${linuxHeaders}/include";
      CLANG = "${clang}/bin/clang";
    };

    meta = {
      description = "bandwidth shaping and network traffic management tool with ebpf";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
      mainProgram = "harper";
    };
  }
