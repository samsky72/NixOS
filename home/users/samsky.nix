{ config, pkgs, lib, defaultUser, ... }:

{
  imports = [
    ../modules/xdg.nix
    ../modules/git.nix
    ../modules/kitty.nix
    ../modules/packages.nix
  ];

  home.username = defaultUser;
  home.homeDirectory = "/home/${defaultUser}";

}

