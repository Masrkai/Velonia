# Langs/julia.nix
# julia runtime -> dev/registry.nix (editor tooling).
{pkgs, ...}: let
  juliaEnv = pkgs.julia-bin.withPackages ["CSV" "HTTP" "Plots" "DataFrames" "LanguageServer"];
in {
  environment.systemPackages = [juliaEnv];
  system.extraDependencies = [juliaEnv.inputDerivation];
}
