{
  description = "Samsky NixOS configuration";

  ##############################
  ## Flake inputs (dependencies)
  ##############################
  inputs = {
    # Base system packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager (user-level)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NUR (Nix User Repository)
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixvim (system-level Neovim config module)
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  ##############################
  ## Flake outputs
  ##############################
  outputs = inputs@{ self, nixpkgs, home-manager, nur, nixvim, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      stateVersion = "24.05";

      # Define users for this repo
      users = { guest = "guest"; samsky = "samsky"; };
      defaultUser = users.samsky;

      ###################################
      ## Function: Build NixOS Host
      ###################################
      mkHost = hostName: lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs hostName stateVersion defaultUser; };

        modules = [
          # Host and shared config
          ./hosts/${hostName}/configuration.nix
          ./modules/system.nix

          # --- Add NUR overlay globally ---
          { nixpkgs.overlays = [ nur.overlays.default ]; }

          # --- Add nixvim module at system level ---
          inputs.nixvim.nixosModules.nixvim

          # --- Home Manager integration ---
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs hostName defaultUser stateVersion; };
            home-manager.users.${defaultUser} = import ./home/home.nix;
          }
        ];
      };
    in {
      nixosConfigurations = {
        zephyrus = mkHost "zephyrus";
      };
    };
}
