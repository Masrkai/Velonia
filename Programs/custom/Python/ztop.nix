{ pkgs }:

let
  mkPythonScript = { name, deps ? [] }:
    let
      pythonEnv = pkgs.python312.withPackages (ps: with ps; deps);
    in
    pkgs.writeScriptBin name ''
      #!${pythonEnv}/bin/python
      ${builtins.readFile ./${name}.py}
    '';

in {
  ctj = mkPythonScript { name = "ctj"; deps = [ pkgs.python312Packages.pyvips ]; };
  mac-formatter = mkPythonScript { name = "mac-formatter"; };
  # MD-PDF = mkPythonScript { name = "MD-PDF";
  #   deps = with pkgs.python312Packages; [ fire markdown2 weasyprint ];
  # };
}
