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
    citrix_workspace                                        # Citrix_workspace - Citrix ICA client.
    fastfetch                                               # Fastfetch - System information fetcher like neofetch.
    psmisc                                                  # Psmsc - process control.
    mc                                                      # Midnight Commander - File manager.
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
    adb.enable = true;                                      # ADB - Android Debug bridge support.
    bash = {                                                # Bash - Bash terminal configuration.
      completion.enable = true;
      interactiveShellInit = shellInit;
      inherit shellAliases;
    };
    firefox.enable = true;                                  # Firefox - Web browser.
    htop.enable = true;                                     # HTop - CLI process status viewer.
    wireshark = {                                           # Wireshark - Network sniffer.
      enable = true;
      package = pkgs.wireshark-qt;
    };
    zsh = {                                                 # Zsh - Zsh terminal configuration.
      enable = true;
      interactiveShellInit = shellInit;
      inherit shellAliases;
    }; 
  };

  # Set default timezone.
  time.timeZone = "Asia/Oral";

}
