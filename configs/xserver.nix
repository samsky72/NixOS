# X server configurations.
{ config, pkgs, ...}: {

  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    xkb = {
      layout = "us,ru";
      options = "terminate:ctrl_alt_bksp,grp:alt_shift_toggle";
    };
  };

}
