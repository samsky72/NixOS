# Nix and nixpkgs default configurations.
{ config, pkgs, ... }: {
  nix = {
    extraOptions = "experimental-features = nix-command flakes";    # Enable flakes.
    gc = {
      dates = "weekly";                                             # Set weekly auto garbage collection.
      automatic = true;
    };
    optimise = {
      dates = [ "weekly" ];                                         # Set weekly auto optimise nix store.
      automatic = true;
    };
    settings = {
      auto-optimise-store = true;                                   # Automatic optimise store on rebuild. 
      max-jobs = 12;                                                # Set maximum parallel jobs.
    };
  };
  nixpkgs = {
    config = {
      allowUnfree = true;                                           # Allow unfree packages.
      allowAliases = true;                                          # Allow packages aliases.
      permittedInsecurePackages = [
        "qtwebkit-5.212.0-alpha4"                                   # Allow insecure qtwebkit.
      ];
    };
  };
} 
