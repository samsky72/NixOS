# Nix and nixpkgs configuration.
{ config, pkgs, ... }: {

  # Use nixd LSP server.
  environment.systemPackages = with pkgs; [
    nixd
  ];

  # Nix package manager configurations.
  nix = {
    
    # Garbage collection configurations.
    gc = {
      automatic = true;                                     # Automatic garbage collection.
      dates = "weekly";                                     # On weekly base.
      options = "-d" ;                                      # Cleanup.
    };


    # Nix settings.
    settings = {
      auto-optimise-store = true;                           # Enable auto optimise store.
      experimental-features = [ "flakes" "nix-command" ];   # Use flakes and nix commands.
    };
  
  };
  
  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;
}
