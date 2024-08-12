# Virtualisation configuration.
{ config, pkgs, ... }: {

  # Libvirt configuration.
  virtualisation.libvirtd = {
    enable = true;
      qemu = {
      package = pkgs.qemu_full;         # Full QEMU in use. 
    };
  };  
}
