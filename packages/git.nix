# Git configuration.
{ config, ... }:
let
  user = "samsky";
in {
  home-manager.users.${user}.programs.git = {
    enable = true;
    ignores = [ "*.bak" ];
    userName = "Samsky72";
    userEmail = "samsky72@gmail.com";
  };
}
