# Multimedia configurations.
{ config, pkgs, ... }: {
   imports = [
     ../packages/mpv.nix
   ];

   environment.systemPackages = with pkgs; [
     djvulibre
     smplayer
     spotify
   ];

   security.rtkit.enable =true;

   services.pipewire = {
     enable = true;
     pulse.enable = true;
   };
}
