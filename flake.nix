{
  description = "Samsky systems flake configurations";

  # Inputs repos.
  inputs = {

    # Use Home Manager.
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";                         # Home Manager follow nixpkgs.
      url =  "github:nix-community/home-manager";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";          # Use unstable repo.
    nur.url = "github:nix-community/NUR";                         # Use Nix Users Repository.
  };

  # Outputs configurations.  
  outputs = inputs@{ self, home-manager, nixpkgs, nur, ... }:
  let
    # Define hosts.
    hosts = {
      helios = "helios";                                          # Acer Helios 500.
      legion = "legion";                                          # Lenovo Legion 7.
      scar = "scar";                                              # Asus Scar Strix 17.
      zephyrus = "zephyrus";                                      # Asus Zephyrus Duo 16.
    };

    # NixOS configuration function.
    lib = hostName: nixpkgs.lib.nixosSystem {
       inherit system;
       modules = module hostName;
       specialArgs = { inherit stateVersion; inherit userName; }; 
    };

    # Define modules function.
    module = hostName: [
      ./configs/configuration.nix                                 # Unified configurations.
      ./hosts/${hostName}.nix                                     # For different laptops.
      
      # Home Manager modules configurations.
      home-manager.nixosModules.home-manager {						
        home-manager = {
          extraSpecialArgs = { inherit stateVersion; inherit userName; };
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${userName} = import ./home-manager/home.nix;
        }; 
      }

      # Define NUR overlay. 
      { nixpkgs.overlays = [ nur.overlay ]; }		
    ];
    
    stateVersion = "24.05";                                       # Initial state version.
    system = "x86_64-linux";                                      # Host system.
    userName = "samsky";                                          # Default user - samsky.
  in {   
    nixosConfigurations = {
      ${hosts.helios} = lib hosts.helios;                         # Acer Helios 500 configurations.
      ${hosts.legion} = lib hosts.legion;                         # Lenovo Legion 7 configurations.
      ${hosts.scar} = lib hosts.scar;                             # Asus Scar 17 configurations.
      ${hosts.zephyrus} = lib hosts.zephyrus;                     # Asus Zephyrus Duo 16 configurations.
    };
  };
}
