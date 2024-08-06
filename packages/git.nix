# Git configuration.
{ config, userName, ... }: {

  # Enable git.
  programs.git.enable = true;

  # Git configuration.
  home-manager.users.${userName}.programs.git = {
    enable = true;
    ignores = ["*.bak" "*.kate-swp" ];
    userName = "Samsky72";
    userEmail = "samsky72@gmail.com";
  };
}
