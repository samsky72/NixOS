{
  description = "Samsky NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      stateVersion = "24.05";  
      # Simple map of users you manage in this repo
      users = { guest = "guest"; samsky = "samsky"; };
      defaultUser = users.samsky;

      # Function to build a NixOS config for a given host
      mkHost = hostName: lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs hostName stateVersion; };
        modules = [
          ./hosts/${hostName}/configuration.nix
          ./modules/system.nix
          home-manager.nixosModules.home-manager
          {
            # Make inputs/hostName available inside HM modules too (optional)
            home-manager.extraSpecialArgs = { inherit inputs hostName defaultUser stateVersion; };
            # HM user is chosen via defaultUser
            home-manager.users.${defaultUser} = import ./home/${defaultUser}.nix;
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        zephyrus = mkHost "zephyrus";
      };
    };
}
