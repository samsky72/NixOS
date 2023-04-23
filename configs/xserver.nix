# X11 configurations.
{ config, pkgs, ... }: {
  hardware.opengl = {
    driSupport = true;                                # Enable DRI support.
    driSupport32Bit = true;                           # With 32 bit support.
    enable = true;                                    # Enable OpenGL support.
    setLdLibraryPath = true;                          # Use LD_LIBRARY_PATH environment variable.
  };
  services.xserver = {
    displayManager = {
      lightdm = { 
	enable = true;                                # Use lightdm as display manager.
      };
    };
    enable = true;                                    # Enable X11.
    excludePackages = [ pkgs.xterm ];                 # Exclude xterm.
    layout = "us, ru";                                # Configure keymap in X11.
    xkbOptions = "grp:alt_shift_toggle";              # Switch keyboard layout on Alt+Shift. 
  };
}
