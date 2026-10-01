{ pkgs, ... }:

{
   environment.systemPackages = with pkgs; [
    mermaid-cli

    plantuml
      graphviz         # Required for diagram layout
      jdk           # Or jre, temurin-jre, etc
  ];
}