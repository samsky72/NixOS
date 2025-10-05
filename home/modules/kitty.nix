# home/modules/kitty.nix
{ ... }: {

  ##########################################
  ## Kitty Terminal Configuration (Home Manager)
  ##########################################
  ##
  ## This module configures the Kitty terminal emulator
  ## with custom fonts, visuals, mouse trails, and keybindings.
  ## All settings are rendered directly into ~/.config/kitty/kitty.conf.
  ##########################################

  programs.kitty = {
    enable = true;

    ##########################################
    ## Appearance
    ##########################################
    # Optional theme (requires kitty-themes package)
    # theme = "Catppuccin-Mocha";

    font = {
      name = "JetBrainsMono Nerd Font";  # or another Nerd Font
      size = 12.0;
    };

    settings = {
      ##########################################
      ## Behavior & Visuals
      ##########################################
      enable_audio_bell = "no";       # disable terminal bell
      confirm_os_window_close = "0";  # skip confirmation prompt
      cursor_shape = "beam";          # modern beam cursor
      cursor_blink_interval = "0";    # disable blinking cursor
      background_opacity = "0.95";    # slightly transparent background

      # Scrolling and layout
      scrollback_lines = 5000;
      window_padding_width = 4;

      ##########################################
      ## Mouse Trails
      ##########################################
      # Adds a smooth trail to the mouse cursor (Wayland/GL only)
      cursor_trail = 1;            # enable mouse trails (1 = on)
      #      cursor_trail_decay = 1;    # how quickly the trail fades (0.1–1.0)
      cursor_trail_length = 3;     # how many frames the trail lasts (higher = longer)
    };

    ##########################################
    ## Keybindings
    ##########################################
    keybindings = {
      "ctrl+shift+t" = "new_tab";        # open new tab
      "ctrl+shift+w" = "close_tab";      # close tab
      "ctrl+shift+enter" = "new_window"; # open new window
    };

    ##########################################
    ## Extra Configuration
    ##########################################
    extraConfig = ''
      # Example: include custom color theme
      # include theme.conf
    '';
  };
}

