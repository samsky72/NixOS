# Zsh configuration.
{ config, pkgs, ...}: 
let
  user = "samsky";
in {
  environment.systemPackages = with pkgs;
  [
    zsh
    zsh-powerlevel10k
  ];
  home-manager.users.${user}.programs.zsh = {
    autocd = true;
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
     initExtra = ''
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
      (cat ~/.cache/wal/sequences &)
      source ~/.cache/wal/colors.sh; 
      source ~/.p10k.zsh
    '';
    shellAliases = {
      ll = "ls -lah";
      ytd = "yt-dlp -f \"(bv*[vcodec~='^((he|a)vc|h26[45])']+ba) / (bv*+ba/b)\" ";
      ncg = "nix-collect-garbage -d && sudo nix-collect-garbage -d && sudo nix store optimise";
      update = "cd ~/NixOS && cp flake.lock flake.lock.$(date -Idate).bak && nix flake update && sudo nixos-rebuild switch --flake '.#'";
      rebuild = "cd ~/NixOS && sudo nixos-rebuild switch --flake '.#'";
    };
    oh-my-zsh.enable = true; 
  };
  programs.zsh = {
    enable = true;
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  };
}
