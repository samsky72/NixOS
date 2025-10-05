# home/modules/packages.nix
{ pkgs, ... }:
{
  ##########################################
  ## User Packages (Home Manager)
  ##########################################
  home.packages = with pkgs; [
    # Terminals
    kitty

    # Browsers
    firefox

    # CLI tools
    git
    curl
    wget
    htop
    neovim
  ];
}
