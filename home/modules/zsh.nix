# home/modules/zsh.nix
# =============================================================================
# Zsh + Starship (theme from flake `colorScheme`, aligned with Stylix)
#
# Intent
#   • Provide a fast Zsh with completion, autosuggestions, and syntax highlighting.
#   • Render a compact, single-line Starship prompt using the Base16 palette from
#     the flake (`colorScheme.palette`). Stylix uses the same scheme for consistency.
#
# Notes
#   • Palette is read from `colorScheme.palette` (provided via flake `extraSpecialArgs`).
#   • “Hard” Powerline separators are used:  (left cap),  (joins),  (right cap).
#   • Global shell aliases live in a system module to avoid duplication.
# =============================================================================
{ config, pkgs, lib, colorScheme, ... }:

let
  # Ensure palette entries are "#RRGGBB".
  withHash = v: if lib.hasPrefix "#" v then v else "#${v}";

  # Base16 palette (base00..base0F) from the flake.
  p = lib.mapAttrs (_: withHash) colorScheme.palette;

  # Segment color mapping (dark-biased).
  seg1 = p.base0E;  # left cap / username (purple-ish accent)
  seg2 = p.base00;  # current directory (darkest)
  seg3 = p.base01;  # VCS section      (dark +1)
  seg4 = p.base02;  # langs/toolchain  (dark +2)
  seg5 = p.base03;  # misc blocks      (dim gray)
  seg6 = p.base00;  # right-most time  (darkest again)
in
{
  ##############################################################################
  ## Companion CLIs (high signal, low footprint)
  ##############################################################################
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "--height 40%" "--border" ];
    fileWidgetCommand = "fd --hidden --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # transparent Nix shell per directory
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat.enable = true;

  ##############################################################################
  ## Prompt: Starship (colors derived from flake palette; HARD corners)
  ##############################################################################
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # Hard separators:
      #   • Left cap  :   (fg = next segment color)
      #   • Joiners   :   (fg = prev seg, bg = next seg)
      #   • Right cap :   (fg = last segment color)
      format =
        "[](fg:${seg1})"
        + "$os$username"
        + "[](bg:${seg2} fg:${seg1})"
        + "$directory"
        + "[](fg:${seg2} bg:${seg3})"
        + "$git_branch$git_status"
        + "[](fg:${seg3} bg:${seg4})"
        + "$c$elixir$elm$golang$gradle$haskell$java$julia$nodejs$nim$rust$scala"
        + "[](fg:${seg4} bg:${seg5})"
        + "$docker_context"
        + "[](fg:${seg5} bg:${seg6})"
        + "$time"
        + "[ ](fg:${seg6})";

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

      # Language/tool blocks share seg4
      c       = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      cpp     = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      elixir  = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      elm     = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      golang  = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      gradle  = {                    style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      haskell = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      java    = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      julia   = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      nodejs  = { symbol = "";  style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      nim     = { symbol = "󰆥 "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      rust    = { symbol = "";  style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };
      scala   = { symbol = " "; style = "bg:${seg4}"; format = "[ $symbol ($version) ]($style)"; };

      docker_context = {
        symbol = " ";
        style = "bg:${seg5}";
        format = "[ $symbol $context ]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";  # 24h HH:MM
        style = "bg:${seg6}";
        format = "[ ♥ $time ]($style)";
      };
    };
  };

  ##############################################################################
  ## Zsh (Home Manager native)
  ##############################################################################
  programs.zsh = {
    enable = true;

    # Absolute XDG path keeps dotfiles tidy and avoids deprecation warnings.
    dotDir = "${config.xdg.configHome}/zsh";

    enableCompletion = true;          # compinit + standard completion
    autosuggestion.enable = true;     # inline suggestions
    syntaxHighlighting.enable = true; # zsh-syntax-highlighting

    defaultKeymap = "viins";          # vi-insert by default
    autocd = true;                    # type a directory name to cd into it

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

