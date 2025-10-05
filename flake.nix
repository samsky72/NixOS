{
  # A short description of your flake — shows up in `nix flake info`
  description = "Samsky NixOS configuration";

  ##############################
  ## Flake inputs (dependencies)
  ##############################
  inputs = {
    # Track the unstable branch of nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager pinned against the same nixpkgs input
    home-manager = {
      url = "github:nix-community/home-manager";
      # This makes HM use the same nixpkgs revision, ensuring compatibility
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  ##############################
  ## Flake outputs (what this flake provides)
  ##############################
  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      # Target system architecture
      system = "x86_64-linux";

      # Convenience alias for nixpkgs lib (useful helper functions)
      lib = nixpkgs.lib;

      # NixOS release version used for backwards compatibility
      stateVersion = "24.05";

      # List of users managed in this repo
      users = {
        guest = "guest";
        samsky = "samsky";
      };

      # Default user for this host (used by system + Home Manager)
      defaultUser = users.samsky;

      ###################################
      ## Function to build a NixOS system
      ###################################
      mkHost = hostName: lib.nixosSystem {
        inherit system;

        # Pass global variables into all modules
        # so they can access `inputs`, `hostName`, etc.
        specialArgs = { inherit inputs hostName stateVersion defaultUser; };

        # Module list defines the entire system composition
        modules = [
          # Machine-specific configuration
          ./hosts/${hostName}/configuration.nix

          # Shared system-level configuration
          ./modules/system.nix

          # Home Manager as a NixOS module
          home-manager.nixosModules.home-manager

          {
            ###################################
            ## Home Manager configuration hook
            ###################################

            # Pass the same arguments into Home Manager
            home-manager.extraSpecialArgs = { inherit inputs hostName defaultUser stateVersion; };

            # Bind the default user’s Home Manager configuration
            home-manager.users.${defaultUser} = import ./home/home.nix;
          }
        ];
      };
    in
    ##############################################
    ## Define all NixOS configurations (per host)
    ##############################################
    {
      nixosConfigurations = {
        # Example host: "zephyrus"
        zephyrus = mkHost "zephyrus";

        # You can easily add more hosts like:
        # atlas = mkHost "atlas";
        # desktop = mkHost "desktop";
      };
    };
}
