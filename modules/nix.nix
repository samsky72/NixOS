# modules/nix.nix
{ lib, pkgs, ... }:
{
  ##########################################
  ## Enable modern Nix features and options
  ##########################################
  nix.settings = {
    # Enable the modern Nix CLI + flakes
    experimental-features = [ "nix-command" "flakes" ];

    # Performance and store optimizations
    auto-optimise-store = true;  # deduplicate identical paths
    cores = 0;                   # use all CPU cores
    max-jobs = "auto";           # parallel builds

    # Allow flakes to define nixConfig (for substituters, etc.)
    accept-flake-config = true;
  };

  ##########################################
  ## Nixpkgs configuration (optional)
  ##########################################
  nixpkgs.config.allowUnfree = true;
}
