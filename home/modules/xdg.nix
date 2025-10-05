# home/modules/xdg.nix
{ config, lib, ... }:
{
  ##########################################
  ## XDG user directories (Home Manager)
  ##########################################

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    # Optionally, you can customize names or locations:
    # desktop = "${config.home.homeDirectory}/desk";
    # documents = "${config.home.homeDirectory}/Docs";
    # downloads = "${config.home.homeDirectory}/DL";
  };

  ##########################################
  ## Optional: XDG base directories
  ##########################################
  xdg = {
    cacheHome  = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome   = "${config.home.homeDirectory}/.local/share";
    stateHome  = "${config.home.homeDirectory}/.local/state";
  };
}
