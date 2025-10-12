# home/modules/stylix-targets.nix
# -----------------------------------------------------------------------------
# Stylix targets — I enable theming for apps/desktops I use.
# System-wide palette/fonts come from the flake (stylix.base16Scheme etc.).
# I import this module once in my user's home.nix.
# -----------------------------------------------------------------------------
{ defaultUser, ... }:
{
  stylix.targets = {
    # ----- Desktop / Shell -----
    hyprland.enable  = true;   # window manager chrome (borders, etc.)
    hyprpaper.enable = true;   # wallpaper color integration (where supported)
    waybar.enable    = true;   # bar colors

    # ----- Terminal / Prompt / Editor -----
    kitty.enable     = true;   # terminal theme
    starship.enable  = true;   # shell prompt theme
    nixvim.enable    = true;   # Neovim colors (via Stylix)

    # ----- Browsers -----
    firefox = {
      enable = true;
      # I theme my default Firefox profile (same as my username)
      profileNames = [ defaultUser ];
    };

    # ----- App Tookits (requested) -----
    # GTK: applies palette to GTK 3/4 (and many apps on GNOME/Wayland)
    gtk.enable = true;

    # Qt (Qt5/Qt6): Stylix generates a Kvantum theme + qt5ct/qt6ct config
    # so Qt apps follow the same palette.
    qt.enable = true;
  };
}

