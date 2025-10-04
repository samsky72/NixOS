{ config, pkgs, lib, ... }:

{
  home.username = "samsky";
  home.homeDirectory = "/home/samsky";

  # User packages
  home.packages = with pkgs; [
    kitty
    firefox
    git
  ];

  # XDG user dirs and auto-create on login
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    # Optionally customize names/paths:
    # desktop = "${config.home.homeDirectory}/desk";
  };

  # Simple kitty config example
  xdg.configFile."kitty/kitty.conf".text = ''
    font_size 12.0
    enable_audio_bell no
    confirm_os_window_close 0
  '';

  programs.git = {
    enable = true;
    userName = "samsky";
    userEmail = "you@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # You can manage Hyprland from HM too (optional starter):
  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   settings = {
  #     monitor = [ "eDP-1,1920x1080@60,0x0,1" ];
  #     exec-once = [ "kitty" "waybar" ];
  #     input.kb_layout = "us";
  #   };
  # };

  # Keep in sync with your first HM version usage
  home.stateVersion = "24.05";
}

