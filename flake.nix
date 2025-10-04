{
  description = "Samsky NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Pin HM against the same nixpkgs input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      hostName = "zephyrus";
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in {
      nixosConfigurations.${hostName} = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; inherit hostName; };
        modules = [
          ./hosts/zephyrus/configuration.nix
          ./modules/system.nix
          home-manager.nixosModules.home-manager

          # Hook Home Manager to user 'samsky' via module file
          { home-manager.users.samsky = import ./home/modules/samsky.nix; }
        ];
      };
    };
}
