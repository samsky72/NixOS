{ config, pkgs, lib, inputs, defaultUser, ... }:

{
  imports = [
    ../modules/xdg.nix
    ../modules/git.nix
    ../modules/kitty.nix
    ../modules/packages.nix

    # Import nixvim’s Home Manager module
    inputs.nixvim.homeManagerModules.nixvim
  ];

  home.username = defaultUser;
  home.homeDirectory = "/home/${defaultUser}";

}

