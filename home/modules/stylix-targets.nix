# home/modules/stylix-targets.nix
# =============================================================================
# Stylix Targets
#
# Description:
#   • Enables Stylix theming for supported desktops and applications
#   • The base color palette and fonts are defined in the flake
#     (via stylix.base16Scheme and related settings)
#   • Imported once in the user's home.nix
#
# Notes:
#   • Ensures consistent theming across Wayland, terminal, editor, and browsers
#   • Applies both GTK and Qt integration for graphical applications
# =============================================================================
{ defaultUser, ... }:

{
  stylix.targets = {
    ##########################################
    ## Desktop environment components
    ##########################################
    hyprland.enable  = true;  # Window manager elements (borders, layout, etc.)
    hyprpaper.enable = true;  # Wallpaper color synchronization (where supported)
    waybar.enable    = true;  # Panel and widget theming
    mako.enable      = true; # Enables Stylix theming for notifications
    ##########################################
    ## Terminal, prompt, and editor
    ##########################################
    kitty.enable     = true;  # Terminal color scheme
    starship.enable  = true;  # Shell prompt theming
    nixvim.enable    = true;  # Neovim integration via Stylix

    ##########################################
    ## Web browsers
    ##########################################
    firefox = {
      enable = true;
      # Applies Stylix theme to the Firefox profile matching the username
      profileNames = [ defaultUser ];
    };

    ##########################################
    ## Application toolkits
    ##########################################
    gtk.enable = true;  # GTK 3/4 applications (GNOME and Wayland apps)
    qt.enable  = true;  # Qt5/Qt6 apps (via Kvantum and qt5ct/qt6ct)
  };
}


