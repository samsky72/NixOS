# modules/nix.nix
{ ... }: {

  ##########################################
  ## Modern Nix Configuration (Flake Ready)
  ##########################################
  nix = {
    settings = {
      ##########################################
      ## Core Nix features
      ##########################################
      experimental-features = [ "nix-command" "flakes" ]; # Enable modern CLI + flakes
      auto-optimise-store = true;                         # Deduplicate identical paths in store
      accept-flake-config = true;                         # Allow flake-defined nixConfig
      cores = 0;                                          # Use all CPU cores
      max-jobs = "auto";                                  # Auto parallelism for builds

      ##########################################
      ## Debugging / store behavior
      ##########################################
      keep-outputs = true;      # Keep build outputs for debugging / reproducibility
      keep-derivations = true;  # Keep derivations to inspect build dependencies
    };

    ##########################################
    ## Garbage Collection
    ##########################################
    gc = {
      automatic = true;                # Enable automatic garbage collection
      dates = "weekly";                # Run GC once a week
      options = "--delete-older-than 14d"; # Remove store paths older than 14 days
    };
 };

  ##########################################
  ## Nixpkgs configuration
  ##########################################
  nixpkgs.config.allowUnfree = true;     # Allow unfree packages globally
}

