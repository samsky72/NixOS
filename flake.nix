{
  description = "Samsky flake";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stable-nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";	
    home-manager = { 
      url = "github:nix-community/home-manager"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR"; 
  };

  outputs = inputs@{ self, nixpkgs, stable-nixpkgs, home-manager, nur, ... }: 
    let 
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
      overlay-stable = final: prev: {
        stable = import stable-nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };
      users = {
        samsky = "samsky";
      };
    in {
      
      # Configuration for Lenovo Legion 7
      nixosConfigurations.legion = lib.nixosSystem {
        inherit system;
        modules = [ 
          ./configs/configuration.nix
          ./machines/legion7.nix 
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${users.samsky} = import ./hm/home.nix;
          }  
          { nixpkgs.overlays = [ nur.overlay 
                                 overlay-stable]; }
        ];
      };
      
      # Configuration for Acer Helios Predator 500
      nixosConfigurations.predator = lib.nixosSystem {
        inherit system;
        modules = [
          ./configs/configuration.nix
          ./machines/helios500.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${users.samsky} = import ./hm/home.nix; 
          }
        ]; 
      }; 
    };
}
