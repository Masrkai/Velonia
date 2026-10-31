{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    clock24 = true;

    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;

    keyMode = "vi";
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      yank
      sensible
      tokyo-night-tmux
    ];

    extraConfigBeforePlugins = ''
      set -g @tokyo-night-tmux_theme night
      set -g @tokyo-night-tmux_transparent 0
      set -g @tokyo-night-tmux_window_id_style digital
    '';
    extraConfig = builtins.readFile ../Services/App_configs/tmux.conf;
  };
}
