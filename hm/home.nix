{ config, pkgs, ...}: { 
  imports = [
    ./homepackages.nix
    ./xdg.nix 
  ];
  home.file."Pictures/Wallpapers/Wallpaper.png".source = ../dotfiles/Wallpaper.png;
  # SMPlayer configuration
  home.file.".config/smplayer/smplayer.ini".source= ../dotfiles/smplayer.ini;
  nixpkgs.config = {
    allowUnfree = true;
    allowAliases = true;
  };
  home.stateVersion = "22.11";
}

