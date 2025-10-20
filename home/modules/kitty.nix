# home/modules/kitty.nix
# =============================================================================
# Kitty (Home Manager) — Stylix-driven colors + flake-provided font
#
# Intent
#   • Defer ALL colors to Stylix (keeps one source of truth for theming)
#   • Read the preferred monospace font from the flake (`font`) instead of
#     hardcoding it here (with a safe Stylix fallback)
#   • Keep only non-color Kitty options locally (cursor, padding, scrollback, etc.)
#   • Provide practical keybindings and a small Wayland clipboard helper
#
# Notes
#   • `stylix.targets.kitty.enable = true;` should be set somewhere (your
#     `stylix-targets.nix` already does this). This file assumes Stylix will
#     inject the Base16 palette into Kitty.
#   • Opacity is left as mkDefault here so another module (or Stylix) can win.
#   • `font` is passed via flake `specialArgs`; if absent, falls back to Stylix’
#     configured monospace font.
# =============================================================================
{ config, lib, pkgs, font ? null, ... }:

let
  # Font selection:
  # - First choice: the `font` string from the flake (e.g., "JetBrainsMono Nerd Font")
  # - Fallback: Stylix’ configured monospace font name
  fontName =
    if font != null then font
    else lib.attrByPath [ "stylix" "fonts" "monospace" "name" ] "JetBrainsMono Nerd Font" config;
in
{
  programs.kitty = {
    enable = true;

    ############################################################################
    ## Appearance (non-color; colors come from Stylix)
    ############################################################################
    font = {
      name = fontName;     # uses flake-provided `font` (fallback to Stylix)
      # size = 11;         # uncomment to pin a default size
    };

    settings = {
      # ----- Behavior & visuals (safe to keep local) --------------------------
      enable_audio_bell       = "no";   # silent bell
      confirm_os_window_close = "0";    # no close prompt
      cursor_shape            = "beam"; # beam|block|underline
      cursor_blink_interval   = "0";    # no blinking
      scrollback_lines        = 5000;   # history size
      window_padding_width    = 6;      # inner padding
      allow_hyperlinks        = "yes";  # clickable terminal hyperlinks

      # Subtle GL trail helps track cursor in dense output
      cursor_trail        = 1;          # 0=off, 1=on
      cursor_trail_length = 3;

      # Leave opacity soft-defaulted so Stylix or another module can override
      background_opacity = lib.mkDefault "0.95";
      # dynamic_background_opacity = "yes";  # enable if animating opacity at runtime
    };

    ############################################################################
    ## Keybindings (common, low-friction)
    ## Reference: https://sw.kovidgoyal.net/kitty/actions/
    ############################################################################
    keybindings = {
      # Tabs & windows
      "ctrl+shift+t"     = "new_tab";
      "ctrl+shift+w"     = "close_tab";
      "ctrl+shift+enter" = "new_window";
      "ctrl+pgup"        = "previous_tab";
      "ctrl+pgdown"      = "next_tab";

      # Clipboard
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";

      # Zoom
      "ctrl+plus"  = "increase_font_size";
      "ctrl+minus" = "decrease_font_size";
      "ctrl+0"     = "reset_font_size";

      # URL hints
      "ctrl+shift+u" = "kitten hints --type=url --program default";

      # Fine scroll
      "ctrl+shift+up"   = "scroll_line_up";
      "ctrl+shift+down" = "scroll_line_down";
      "ctrl+shift+home" = "scroll_home";
      "ctrl+shift+end"  = "scroll_end";
    };

    ############################################################################
    ## Extra config hook (kept empty by default)
    ############################################################################
    extraConfig = ''
      # Additional snippets can be placed here if needed.
    '';
  };

  ##############################################################################
  ## Helper packages (Wayland clipboard)
  ##############################################################################
  home.packages = with pkgs; [
    wl-clipboard  # wl-copy / wl-paste
  ];

  ##############################################################################
  ## Stylix integration (colors come from Stylix)
  ## - Enabling here with mkDefault is harmless if already enabled elsewhere.
  ##############################################################################
  stylix.targets.kitty.enable = lib.mkDefault true;
}

