# PolyBar configuration.
{ config, pkgs, ... }:
let
  user = "samsky";
in {
  environment.systemPackages = with pkgs; [ polybarFull ];        # Support full version.
  home-manager.users.${user}.home.file.".config/polybar/config.ini".source = ../dotfiles/config.ini;
}

