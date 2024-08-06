# System environmentconfigurations.
{ config, pkgs, ... }:

  let
    # Define shell alisases.
    shellAliases = {
      ll = "ls -lah";
      system-rebuild = "cd ~/NixOS && sudo nixos-rebuild switch --flake .";
      system-update = "cd ~/NixOS && nix flake update && sudo nixos-rebuild switch --flake .";
      system-cleanup = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
    };
    shellInit = "fastfetch && cd ~/NixOS";
  in {

  # Import required packages
  imports = [
    ../packages/git.nix
  ];

  # Define system wide packages.
  environment.systemPackages =  with pkgs;[
    fastfetch                                               # fastfetch - System information fetcher like neofetch.
    psmisc                                                  # psmsc - process control.
    mc                                                      # midnight Commander - File manager.
  ];

  # Define supported locales.
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"                                         # POSIX default locale.
    "en_US.UTF-8/UTF-8"                                     # US locale.
    "kk_KZ.UTF-8/UTF-8"                                     # Kazakh locale.
    "ru_RU.UTF-8/UTF-8"                                     # Russian locale.
  ];

  # Define SUID programs.
  programs = {
    adb.enable = true;
    bash = {
      completion.enable = true;
      interactiveShellInit = shellInit;
      inherit shellAliases;
    };
    firefox.enable = true;
    htop.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
    };
    zsh = { 
      enable = true;
      interactiveShellInit = shellInit;
      inherit shellAliases;
    }; 
  };

  # Set default timezone.
  time.timeZone = "Asia/Oral";

}
