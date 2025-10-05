{ config, lib, pkgs, inputs, stateVersion, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/boot.nix
    ../../modules/users.nix
    ../../modules/network.nix
    ../../modules/nix.nix
    ../../modules/locale.nix
    ../../modules/hyprland.nix
    ../../modules/portals.nix
    ../../modules/packages.nix
    ../../modules/services.nix
  ];
 
  # Match your current NixOS release for stable state evolution
  system.stateVersion = stateVersion;
}
