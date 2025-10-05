{ config, pkgs, lib, defaultUser, stateVersion, ... }:

{
  imports = [
    ./modules/xdg.nix
    ./modules/git.nix
    ./modules/kitty.nix
    ./modules/packages.nix
    ./users/${defaultUser}.nix
  ];

  # Keep in sync with your first HM version usage
  home.stateVersion = stateVersion;
}

