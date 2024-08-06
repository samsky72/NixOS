# X server configurations.
{ config, pkgs, ...}: {

  # X server setup.
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];                                     # Remove xterm, as lot of terminal may be used.
    xkb = {
      layout = "us,ru";                                                   # US, Russian layout support.
      options = "terminate:ctrl_alt_bksp,grp:alt_shift_toggle";           # Ctrl+Alt+Backspace to reset X server (No wayland),Alt+Shift to layout toggle.
    };
  };

}
