# modules/virtualization.nix
{ pkgs, lib, defaultUser, ... }:

{
  ##########################################
  ## QEMU/KVM + libvirt
  ##########################################
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "start";
    onShutdown = "shutdown";

    qemu = {
      package = pkgs.qemu_kvm;

      # vTPM (useful for Win11/BitLocker, etc.)
      swtpm.enable = true;

      # NOTE:
      # - The 'qemu.ovmf' submodule was removed upstream; OVMF firmware comes
      #   with QEMU by default. No explicit option is needed anymore.
      # - virtiofsd has no libvirtd option; just ensure the binary exists (see packages below).
    };
  };

  programs.virt-manager.enable = true;

  ##########################################
  ## Host packages & helpers
  ##########################################
  environment.systemPackages = with pkgs; [
    virt-viewer
    spice-gtk
    usbredir
    dnsmasq
    bridge-utils
    virtiofsd   # provides /run/current-system/sw/bin/virtiofsd for virtio-fs shares
  ];

  ##########################################
  ## Containers
  ##########################################
  # Choose ONE of the two approaches:
  # A) Docker (classic)  -> set docker.enable = true; podman.enable = false;
  # B) Podman as docker  -> set docker.enable = false; podman.enable = true; podman.dockerCompat = true;

  # A) Docker
  virtualisation.docker.enable = true;

  # B) Podman (installed but NOT pretending to be Docker to avoid conflicts)
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;  # must be false when Docker is enabled
    defaultNetwork.settings.dns_enabled = true;
  };

  ##########################################
  ## User group membership
  ##########################################
  users.users.${defaultUser}.extraGroups =
    lib.mkAfter [ "kvm" "libvirtd" "docker" ];

  # Optional kernel hints (usually auto-detected):
  # boot.kernelModules = [ "kvm" "kvm-intel" "kvm-amd" ];
  # boot.kernelParams  = [ "kvm.ignore_msrs=1" ];
}

