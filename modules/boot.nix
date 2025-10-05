# modules/boot.nix
{ ... }: {

  boot = {
    ##########################################
    ## Bootloader configuration (UEFI setup)
    ##########################################
    loader = {
      # Enable systemd-boot (recommended for EFI systems)
      systemd-boot.enable = true;

      # Allow NixOS to modify EFI variables (register boot entries)
      efi.canTouchEfiVariables = true;

      # Time (in seconds) before automatically booting default entry
      timeout = 3;
    };

    ##########################################
    ## Kernel options
    ##########################################
    # "quiet" hides most kernel messages
    # "loglevel=3" reduces console spam to warnings/errors only
    kernelParams = [ "quiet" "loglevel=3" ];
 };
}

