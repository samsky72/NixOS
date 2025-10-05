# home/modules/git.nix
{ defaultUser, ... }:
{
  ##########################################
  ## Git configuration (Home Manager)
  ##########################################
  ##
  ## Provides a user-level Git setup with sane defaults,
  ## configured via Home Manager. Automatically uses your
  ## flake’s `defaultUser` for identity.
  ##########################################

  programs.git = {
    enable = true;

    ##########################################
    ## Global identity
    ##########################################
    userName = defaultUser;
    userEmail = "${defaultUser}72@gmail.com";

    ##########################################
    ## Common sensible defaults
    ##########################################
    extraConfig = {
      init.defaultBranch = "main";   # use "main" instead of "master"
      pull.rebase = true;            # cleaner pull history
      color.ui = "auto";             # colorize CLI output
      core.editor = "vim";           # default text editor
    };
  };
}

