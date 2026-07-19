{ pkgs, ... }:

{
  environment.systemPackages =
    (with pkgs; [
      doxygen
      doxygen_gui
      doxygen-awesome-css

      monolith
    ])
    ++
    (with pkgs; [
      typst
      # miktex
      python313Packages.panflute

      pandoc
      pandoc-include
      pandoc-ext-diagram

      librsvg
    ]);

  environment.variables = {
    PLANTUML_JAR = "${pkgs.plantuml}/lib/plantuml.jar";
    PANDOC_DIAGRAM_FILTER = "${pkgs.pandoc-ext-diagram}/diagram.lua";
  };
}
