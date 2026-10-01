{ pkgs, ... }:

{


programs.tmux = {
  enable = true;
  clock24 = true;

  baseIndex = 1;
  escapeTime = 0;
  historyLimit = 10000;

  keyMode = "vi";
  terminal = "tmux-256color";   # sets default-terminal

  plugins = with pkgs.tmuxPlugins; [
    yank
    sensible
  ];

  extraConfig = ''
    # anything not covered by the module's options goes here verbatim
  '';
};


}
