{ lib, rustPlatform, iproute2, nftables, ... }:

let
  # Define the absolute path to your project directory
  projectDir = /home/masrkai/Documents/Personal/Projects/Harper;
in
rustPlatform.buildRustPackage {
  pname   = "harper";
  version = "0.1.0";

  # 1. Point src to the absolute project directory
  src = lib.cleanSource projectDir;

  cargoLock = {
    # 2. Point lockFile to the absolute Cargo.lock path
    lockFile = "${projectDir}/Cargo.lock";
  };

  nativeBuildInputs = [ iproute2 nftables ];

  meta = with lib; {
    description = "Per-device bandwidth shaping and network traffic management";
    license     = licenses.mit;
    maintainers = [ "Masrkai" ];
    platforms   = [ "x86_64-linux" "aarch64-linux" ];

    # ⚠️ NOTE: Rust binaries are usually lowercase.
    # Change this to "harbor" unless you explicitly named the binary "Harbor" in Cargo.toml
    mainProgram = "harper";
  };
}
