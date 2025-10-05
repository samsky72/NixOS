{ config, pkgs, lib, inputs, defaultUser, ... }:

{
  imports = [
    ../modules/xdg.nix
    ../modules/git.nix
    ../modules/kitty.nix
    ../modules/packages.nix
    ../modules/hyprland.nix

    # Import nixvim’s Home Manager module
    inputs.nixvim.homeModules.nixvim
  ];

  home.username = defaultUser;
  home.homeDirectory = "/home/${defaultUser}";

}

