# home/modules/xdg.nix
{ config, ... }: {

  ##########################################
  ## XDG user directories (Home Manager)
  ##########################################
  ##
  ## This module configures standard user directories
  ## such as Documents, Downloads, Pictures, etc.
  ## It ensures they exist and follow the XDG specification.
  ##########################################

  xdg.userDirs = {
    enable = true;             # enable XDG user directories
    createDirectories = true;  # auto-create them if missing

    # You can customize any of these paths if desired:
    # desktop   = "${config.home.homeDirectory}/Desktop";
    # documents = "${config.home.homeDirectory}/Documents";
    # downloads = "${config.home.homeDirectory}/Downloads";
    # pictures  = "${config.home.homeDirectory}/Pictures";
    # music     = "${config.home.homeDirectory}/Music";
    # videos    = "${config.home.homeDirectory}/Videos";
  };

  ##########################################
  ## XDG base directory specification
  ##########################################
  ##
  ## These define standardized locations for cache,
  ## config, and application data — keeping your $HOME
  ## clean and predictable.
  ##########################################

  xdg = {
    cacheHome  = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome   = "${config.home.homeDirectory}/.local/share";
    stateHome  = "${config.home.homeDirectory}/.local/state";
  };
}

