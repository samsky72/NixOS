# modules/packages.nix
{ pkgs, ... }:
{
  ##########################################
  ## Base system packages
  ##########################################
  environment.systemPackages = with pkgs; [
    # Core utilities
    git
    curl
    wget
    vim

    gcc

    # Nix helpers
    nixpkgs-fmt
    nix-tree
  ];

}
