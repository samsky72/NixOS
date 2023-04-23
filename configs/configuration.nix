# Default configuration file.
{ config, ... }:
{
  imports = [                           # Import required configurations.
    ./bluetooth.nix
    ./boot.nix
    ./console.nix
    ./environment.nix
    ./fonts.nix
    ./games.nix
    ./i18n.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./programs.nix
    ./services.nix
    ./sound.nix
    ./time.nix
    ./users.nix
    ./virtualisation.nix
    ./xserver.nix
  ];
 
  system.stateVersion = "22.11";        # Default state version.
}
