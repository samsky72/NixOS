{ pkgs, lib, ... }:
{
  programs.kitty = {
    enable = true;

    # Optional: pick a theme by name (from kitty-themes)
    # programs.kitty.theme = "Catppuccin-Mocha";

    # Optional font config
    font = {
      name = "JetBrainsMono Nerd Font";  # or leave unset to use system default
      size = 12.0;
    };

    # Kitty settings (these render directly into kitty.conf)
    settings = {
      # matches your old snippet:
      enable_audio_bell = "no";
      confirm_os_window_close = "0";

      # nice defaults:
      cursor_shape = "beam";
      cursor_blink_interval = "0";
      background_opacity = "0.95";
    };

    # Keybindings (render to kitty.conf)
    keybindings = {
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+enter" = "new_window";
    };

    # Drop in any raw lines not covered by settings/keybindings
    extraConfig = ''
      # include other fragments if you want:
      # include theme.conf
    '';
  };
}
