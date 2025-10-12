# home/modules/zsh.nix
# KISS: HM-native Zsh + tools, colors unified with flake `colorScheme` (darker mapping).
{ config, pkgs, lib, colorScheme, ... }:
let
  # Ensure palette entries are "#RRGGBB"
  withHash = v: if lib.hasPrefix "#" v then v else "#${v}";
  p = lib.mapAttrs (_: withHash) colorScheme.palette;

  # Darker mapping (Tokyo Night vibes):
  seg1 = p.base0E;  # subtle accent (purple) for the left cap/username
  seg2 = p.base00;  # darkest bg (directory)
  seg3 = p.base01;  # dark bg+1 (git)
  seg4 = p.base02;  # dark bg+2 (langs/tools)
  seg5 = p.base03;  # dim gray (docker)
  seg6 = p.base00;  # return to darkest for the time block
in
{
  # Helpers that pair well with Zsh
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "--height 40%" "--border" ];
    fileWidgetCommand = "fd --hidden --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat.enable = true;

  # Starship (powerline-style) colored from your flake theme — darker palette
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Single-line format (avoids TOML backslash issues)
      format = "[](${seg1})$os$username[](bg:${seg2} fg:${seg1})$directory[](fg:${seg2} bg:${seg3})$git_branch$git_status[](fg:${seg3} bg:${seg4})$c$elixir$elm$golang$gradle$haskell$java$julia$nodejs$nim$rust$scala[](fg:${seg4} bg:${seg5})$docker_context[](fg:${seg5} bg:${seg6})$time[ ](fg:${seg6})";

      username = {
        show_always = true;
        style_user = "bg:${seg1}";
        style_root = "bg:${seg1}";
        format = "[$user ]($style)";
        disabled = false;
      };

      os = {
        style = "bg:${seg1}";
        disabled = true;
      };

      directory = {
        style = "bg:${seg2}";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          Documents = "󰈙 ";
          Downloads = " ";
          Music     = " ";
          Pictures  = " ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:${seg3}";
        format = "[ $symbol $branch ]($style)";
      };

      git_status = {
        style = "bg:${seg3}";
        format = "[$all_status$ahead_behind ]($style)";
      };

      docker_context = {
        symbol = " ";
        style = "bg:${seg5}";
        format = "[ $symbol $context ]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:${seg6}";
        format = "[ ♥ $time ]($style)";
      };

      # Language/tool blocks share seg4 (still dark)
      c       = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      cpp     = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      elixir  = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      elm     = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      golang  = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      gradle  = {                   style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      haskell = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      java    = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      julia   = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      nodejs  = { symbol = "";  style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      nim     = { symbol = "󰆥 "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      rust    = { symbol = "";  style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      scala   = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
    };
  };

  # Zsh (HM-native only; aliases live in sysenv.nix)
  programs.zsh = {
    enable = true;

    # Absolute XDG path (no deprecation warning)
    dotDir = "${config.xdg.configHome}/zsh";

    enableCompletion = true;
    autosuggestion.enable = true;   # singular
    syntaxHighlighting.enable = true;

    defaultKeymap = "viins";        # "emacs" | "viins" | "vicmd"
    autocd = true;

    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      size = 50000;
      save = 50000;
      share = true;
      extended = true;
      expireDuplicatesFirst = true;
      ignoreDups = true;
    };
  };
}

