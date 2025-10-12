# home/modules/kitty.nix
# =============================================================================
# Kitty (Home Manager) — my terminal, unified with flake colors
#
# What I want:
# - Nerd Font + truecolor + tidy visuals.
# - Subtle cursor trail (Wayland/GL).
# - Handy keybindings (tabs, copy/paste, URLs, font zoom).
# - Colors pulled straight from my flake `colorScheme` (base16).
#
# Notes:
# - I set background_opacity with mkDefault to avoid conflicts with other modules.
#   If I need to force my value, I’ll change mkDefault -> mkForce.
# =============================================================================
{ config, pkgs, lib, colorScheme, ... }:
let
  # Ensure palette values are "#RRGGBB"
  withHash = v: if lib.hasPrefix "#" v then v else "#${v}";
  p = lib.mapAttrs (_: withHash) colorScheme.palette;

  # Base16 -> Kitty mapping shortcuts
  bg   = p.base00;
  bg2  = p.base02;
  fg   = p.base05;
  acc1 = p.base0D;  # blue-ish
  acc2 = p.base0E;  # purple-ish
  cur  = p.base06;  # bright fg for cursor
in
{
  programs.kitty = {
    enable = true;

    ##########################################
    ## Appearance
    ##########################################
    font = {
      # I use a Nerd Font so powerline/DevIcons render everywhere.
      name = "JetBrainsMono Nerd Font";
      # size = 11;
    };

    # Kitty reads these as kitty.conf keys.
    settings = {
      # --- Behavior & visuals ---
      enable_audio_bell = "no";        # I keep the bell silent
      confirm_os_window_close = "0";   # I skip close confirmation
      cursor_shape = "beam";           # modern thin cursor
      cursor_blink_interval = "0";     # no blinking
      scrollback_lines = 5000;         # enough scrollback for logs
      window_padding_width = 6;        # a little breathing room

      # --- Colors (unified with my flake theme) ---
      background = bg;
      foreground = fg;

      # Selection/cursor I keep readable and on-theme.
      selection_background = bg2;
      selection_foreground = fg;
      cursor               = cur;
      cursor_text_color    = bg;

      # URL/mark colors (minor accents)
      url_color        = acc1;
      mark1_foreground = bg;
      mark1_background = acc1;
      mark2_foreground = bg;
      mark2_background = acc2;

      # 16-color palette (base16)
      color0  = p.base00;  # black
      color1  = p.base08;  # red
      color2  = p.base0B;  # green
      color3  = p.base0A;  # yellow
      color4  = p.base0D;  # blue
      color5  = p.base0E;  # magenta
      color6  = p.base0C;  # cyan
      color7  = p.base05;  # white
      color8  = p.base03;  # bright black
      color9  = p.base08;  # bright red
      color10 = p.base0B;  # bright green
      color11 = p.base0A;  # bright yellow
      color12 = p.base0D;  # bright blue
      color13 = p.base0E;  # bright magenta
      color14 = p.base0C;  # bright cyan
      color15 = p.base07;  # bright white

      # --- Cursor trail (Wayland/GL) ---
      # I keep the trail subtle; increase length for a longer tail.
      cursor_trail        = 1;  # 0 = off, 1 = on
      cursor_trail_length = 3;  # how many frames the trail lasts

      # --- Truecolor & rendering niceties ---
      allow_hyperlinks = "yes";

      # --- Transparency (use mkDefault to avoid conflicts) ---
      background_opacity = lib.mkForce "0.95";
      # If I ever want to *force* my value:
      # background_opacity = lib.mkForce "0.95";
      # dynamic_background_opacity = "yes";  # optional, if I animate opacity
    };

    ##########################################
    ## Keybindings
    ##########################################
    # Kitty actions: https://sw.kovidgoyal.net/kitty/actions/
    keybindings = {
      # Tabs & windows
      "ctrl+shift+t"     = "new_tab";
      "ctrl+shift+w"     = "close_tab";
      "ctrl+shift+enter" = "new_window";
      "ctrl+pgup"        = "previous_tab";
      "ctrl+pgdown"      = "next_tab";

      # Clipboard & paste
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";

      # Font zoom
      "ctrl+plus"  = "increase_font_size";
      "ctrl+minus" = "decrease_font_size";
      "ctrl+0"     = "reset_font_size";

      # URLs (open with hints)
      "ctrl+shift+u" = "kitten hints --type=url --program default";

      # Scroll fine-tune
      "ctrl+shift+up"   = "scroll_line_up";
      "ctrl+shift+down" = "scroll_line_down";
      "ctrl+shift+home" = "scroll_home";
      "ctrl+shift+end"  = "scroll_end";
    };

    ##########################################
    ## Extra Configuration
    ##########################################
    extraConfig = ''
      # I can include extra snippets here, e.g. a theme override:
      # include current-theme.conf
    '';
  };

  ##########################################
  ## Optional helpers I like with Kitty
  ##########################################
  home.packages = with pkgs; [
    wl-clipboard # Wayland clipboard (xclip/xsel equivalents)
  ];
}

