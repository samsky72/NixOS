# Git configuration.
{ config, userName, ... }: {
  programs.git.enable = true;
  home-manager.users.${userName}.programs.git = {
    enable = true;
    ignores = ["*.bak" "*.kate-swp" ];
    userName = "Samsky72";
    userEmail = "samsky72@gmail.com";
  };
}
