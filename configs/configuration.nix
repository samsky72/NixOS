# Samsky systtems configurations.
{ config, stateVersion, ... }: {

  # Import configurations.  
  imports =
    [ 
      ./boot.nix                    # Boot configurations.
      ./games.nix                   # Games configurations.
      ./networking.nix              # Network configurations.
      ./plasma.nix                  # Plasma configurations.
      ./multimedia.nix              # Multimedia  configurations.
      ./sysenv.nix                  # System environment confgurations.
      ./nix.nix                     # Nix and nixpkgs configurations.
      ./users.nix                   # Users configurations.
      ./xserver.nix                 # X server confgurations.
    ];

  # Define initial state version.
  system.stateVersion = stateVersion;
}

