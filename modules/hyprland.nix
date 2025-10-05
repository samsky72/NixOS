# modules/hyprland.nix
{ lib, pkgs, defaultUser ? "samsky", ... }:
{
  ##########################################
  ## Wayland + Hyprland setup
  ##########################################

  # Enable Hyprland compositor (Wayland-native)
  programs.hyprland.enable = true;

  # Disable X11 (optional for pure Wayland setups)
  services.xserver.enable = false;

  # Greeter (login manager) using greetd + tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = defaultUser;
      };
    };
  };

  # (Optional) For smoother fonts, hardware acceleration, etc.
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
