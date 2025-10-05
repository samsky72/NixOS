# home/modules/git.nix
{ lib, pkgs, defaultUser, ... }:
{
  ##########################################
  ## Git configuration (Home Manager)
  ##########################################

  programs.git = {
    enable = true;

    # Global identity
    userName = defaultUser;
    userEmail = "${defaultUser}72@gmail.com";

    # Common sensible defaults
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      color.ui = "auto";
      core.editor = "vim";
    };
  };
}
