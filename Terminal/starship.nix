{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    starship
  ];

  # Enable Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      # Custom format - removed $all to have more control
      format =
        # "╭─ $directory$\{custom.giturl} $git_branch$git_status $python$nodejs$rust$java$golang$docker$package $cmd_duration\n╰─ $username$hostname $time$character";
        let
          line1 = "╭─ $directory\${custom.giturl} $git_branch$git_status $python$nodejs$rust$java$golang$docker$nix_shell$package $cmd_duration";
          line2 = "╰─ $username$hostname $time$character ";
        in
        "${line1}\n${line2}";

      fill = {
        symbol = " ";
      }; # Character configuration
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
        vicmd_symbol = "[](bold yellow)";
      };

      # Username module with custom styling
      username = {
        show_always = true;
        style_user = "bold cyan";
        style_root = "bold red";
        format = "[$user]($style)";
      };

      # Hostname with custom styling
      hostname = {
        ssh_only = false;
        style = "bold orange";
        format = "[@$hostname]($style)";
      };

      # Directory path styling
      directory = {
        style = "bold blue";
        truncation_length = 3;
        truncate_to_repo = false;
      };

      # Git branch and status
      git_branch = {
        style = "bold purple";
        symbol = " ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style))";
        style = "bold red";

        # Add ${count} to each symbol to show numbers
        conflicted = "⚡\${count}";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?\${count}";
        stashed = "$\${count}";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»\${count}";
        deleted = "✘\${count}";
      };

      # Nix shell indicator
      nix_shell = {
        disabled = false;
        impure_msg = "[impure shell](bold red)";
        pure_msg = "[pure shell](bold green)";
        unknown_msg = "[unknown shell](bold yellow)";
        format = " via [$state( \($name\))]($style)";
        style = "bold blue";
        symbol = " ";
      };

      # Python - only show in Python projects
      python = {
        detect_extensions = [
          "py"
          "pyi"
        ];
        detect_files = [
          "requirements.txt"
          "pyproject.toml"
          "Pipfile"
          "setup.py"
          "__init__.py"
        ];
        # detect_folders = [".venv" "venv" "env"];
        symbol = " ";
        style = "yellow";
        format = " via [$symbol$version]($style)";
      };

      # Other language modules - only show when relevant
      nodejs = {
        detect_extensions = [
          "js"
          "mjs"
          "cjs"
          "ts"
        ];
        detect_files = [
          "package.json"
          "node_modules"
        ];
        symbol = " ";
        style = "green";
        format = " via [$symbol$version]($style)";
      };

      rust = {
        detect_extensions = [ "rs" ];
        detect_files = [ "Cargo.toml" ];
        symbol = "󱘗 ";
        style = "brown";
        format = " via [$symbol$version]($style)";
      };

      java = {
        detect_extensions = [
          "java"
          "class"
          "jar"
        ];
        detect_files = [
          "pom.xml"
          "build.gradle.kts"
          "build.sbt"
          ".java-version"
        ];
        symbol = " ";
        style = "red";
        format = " via [$symbol$version]($style)";
      };

      golang = {
        detect_extensions = [ "go" ];
        detect_files = [
          "go.mod"
          "go.sum"
        ];
        symbol = "󰟓 ";
        style = "cyan";
        format = " via [$symbol$version]($style)";
      };

      # Time display (similar to your \t in PS1)
      time = {
        disabled = false;
        style = "bold red";
        format = " [$time]($style) ";
        time_format = "%H:%M";
      };

      # Disable package module to avoid conflicts
      package = {
        disabled = true;
      };

      # Docker module
      # docker = {
      #   symbol = " ";
      #   style = "blue";
      #   format = " via [$symbol$context]($style)";
      # };

      # Command duration
      cmd_duration = {
        # min_time = 500;
        format = " took [$duration]($style)";
        style = "yellow";
      };

      # Custom modules
      custom = {
        giturl = {
          description = "Display symbol for remote Git server";
          command = "${builtins.readFile ./starship_custom/giturl.sh}";
          when = "git rev-parse --is-inside-work-tree 2> /dev/null";
          # shell = ["bash" "-c"];
          style = "bold green";
          format = " at [$output]($style) ";
        };
      };
    };
  };
}
