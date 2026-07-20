{  config, pkgs, lib, ...}:

let
  # Reads a .sh file and extracts package names from any line like:
  #   #NIXPKGS ffmpeg unzip p7zip
  # Step 1: Extract package name strings from a single script file
  extractPkgNames =
    file:
    let
      lines = lib.splitString "\n" (builtins.readFile file);
      nixpkgs = builtins.filter (l: builtins.match "^#NIXPKGS.*" l != null) lines;
    in
    builtins.concatMap (
      l:
      let
        m = builtins.match "^#NIXPKGS +(.*)" l;
      in
      if m != null then builtins.filter (s: s != "") (lib.splitString " " (builtins.head m)) else [ ]
    ) nixpkgs;

  scriptFiles = [
    ./Functions/sudo.sh
    ./Functions/bash.sh
    ./Functions/extract.sh
    ./Functions/compress.sh
    ./Functions/listfonts.sh
    ./Functions/journalctl.sh
    ./Functions/sector_copy.sh
    ./Functions/yt_downloader.sh
    ./Functions/ani-cli-batch.sh
    ./Functions/usb_power_map.sh
    ./Functions/nixos_specific.sh
    ./Functions/convert_to_mp4.sh
    ./Functions/sync_nixos_config.sh
    ./Functions/clean_stale_mount.sh
    ./Functions/convert_ppts_to_pdf.sh
    ./Functions/fzf-bash-completion.sh
    ./Functions/pandocmarkdowntopdf.sh
  ];

  # Step 2: Collect all names across all files, dedupe, then resolve to packages
  scriptPackages = map (name: pkgs.${name}) (
    lib.unique (builtins.concatMap extractPkgNames scriptFiles)
  );

  scriptContent = lib.concatMapStrings (
    f: "\n# --- ${builtins.toString f} ---\n" + builtins.readFile f + "\n"
  ) scriptFiles;
in
{

  programs.bash = {
    enableLsColors = lib.mkForce false;
    completion.enable = true;
    blesh.enable = false;

    interactiveShellInit = ''
      export ANI_CLI_PLAYER=haruna

      ${scriptContent}

      bind -x '"\t": fzf_bash_completion'
      eval "$(${pkgs.starship}/bin/starship init bash)"
    '';

    shellAliases = {
      cl = "printf '\\033c'";

      sudo = "sudo ";
      code = "codium";
      ff = "fastfetch";
      ip = "ip --color=auto";
      anime = "ani-cli -q 720 --dub";
      ascr = "scrcpy --no-audio -Sw --no-downsize-on-error";

      # Verbose output when copying
      cpv = "rsync -avh --info=progress2";

      # Overwrite protection
      cp = "cp -v ";
      mv = "mv -v ";

      # Replacing List command with eza (Read it's help before you edit)
      l = "eza --color=always --group-directories-first --long --icons=always --links -a --tree";
      ls = "eza --color=always --group-directories-first --long --git --icons=always --links";
      lss = "eza --color=always --group-directories-first --long --git --icons=always --total-size --links";

      la = "eza --color=always --group-directories-first --long --git --icons=always --links -A";
      lsa = "eza --color=always --group-directories-first --long --git --icons=always --total-size --links -A";
      lsg = "eza --color=always --group-directories-first --long --git --icons=always --links --group";

      checkcpplibs = "g++ -v -E -x c++ - </dev/null 2>&1 | grep -A 12 '#include <...> search starts here:'";

    };
  };

  environment = {

    #? Set up environment variables for colored man pages
    variables = {
      MANPAGER = lib.mkForce "sh -c 'col -bx | bat -l man -p'"; # * Use bat as the pager for man with syntax highlighting
      LESSOPEN = lib.mkForce "| ${pkgs.lesspipe}/bin/lesspipe.sh %s"; # * Set LESSOPEN to use lesspipe
      LESS = lib.mkForce "-R"; # * Ensure LESS is configured to interpret ANSI color codes correctly
      MANROFFOPT = "-c"; # * Enable colorized output for man pages
    };

    systemPackages = with pkgs; [

        # Terminal
        kitty

        # Nix Tools
        nix-search
        nixos-generators
        nix-prefetch-git

        # watch-like utilities
        viddy
        hwatch

        # essential terminal daily ddriver utilities.
        eza
        bat
        fzf
        less
        ripgrep
        toolong
        termshot
        fastfetch

        # Manuals
        man
        man-pages
        linux-manual
        man-pages-posix

        moreutils
      ]
      ++ scriptPackages; # > auto-collected from #NIXPKGS comments
  };

  #--> mlocate // "updatedb & locate"
  services.locate = {
    enable = true;
    package = pkgs.mlocate;
    # localuser = null;
  };

  programs.less = {
    enable = true;
    envVariables = {
      LESS = "-R --use-color -Dd+r$Du+b";
    };
  };
}
