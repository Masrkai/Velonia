# Langs/julia.nix
# julia runtime -> dev/registry.nix (editor tooling).
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # julia-bin
    (pkgs.julia-bin.withPackages [
      "CSV" "HTTP"
      "Plots" "DataFrames"
      "LanguageServer"
    ])
  ];
}
