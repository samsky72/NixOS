# Virtualisation configuration.
{ config, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    qtemu
  ];
  
  # Libvirt configuration.
  virtualisation.libvirtd = {
    enable = true;
      qemu = {
      package = pkgs.qemu_full;         # Full QEMU in use.
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override { 
          secureBoot = true;
          tpmSupport = true;
        }).fd ];
      };
    };
  };  
}
