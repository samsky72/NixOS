# modules/virtualization.nix
# =============================================================================
# Virtualization: QEMU/KVM + libvirt (+ optional containers)
#
# Provides
#   • libvirtd with QEMU/KVM, vTPM (swtpm), virtio-fs (virtiofsd)
#   • virt-manager GUI
#   • Optional Docker OR Podman (not both)
#
# Notes
#   • OVMF (UEFI firmware) is available with QEMU in modern nixpkgs; no extra toggle.
#   • libvirt manages its own dnsmasq instance; installing dnsmasq globally is not required.
#   • Choose exactly one container engine; enabling both causes confusion/port clashes.
# =============================================================================
{ pkgs, lib, defaultUser, ... }:

let
  # --- Container engine selection --------------------------------------------
  # Set exactly one of these to true:
  useDocker = true;     # classic Docker engine
  usePodman = false;    # rootless Podman (can emulate `docker` CLI)
in
{
  ##########################################
  ## QEMU/KVM + libvirt
  ##########################################
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "start";       # start libvirtd at boot
    onShutdown = "shutdown";

    qemu = {
      package = pkgs.qemu_kvm;  # QEMU with KVM acceleration

      # vTPM: required for Win11, BitLocker, etc.
      swtpm.enable = true;

      # virtiofsd is provided via systemPackages below for host<->guest shared folders
      # OVMF (UEFI) comes with QEMU in modern nixpkgs; no explicit option needed.
    };
  };

  ##########################################
  ## UI & helpers
  ##########################################
  programs.virt-manager.enable = true;  # virt-manager GUI

  # Make tools available system-wide; libvirt will spawn its own dnsmasq.
  environment.systemPackages = with pkgs; [
    virt-viewer          # remote viewer
    spice-gtk            # SPICE client libs
    usbredir             # USB redirection helpers
    virtiofsd            # virtio-fs daemon for host/guest sharing
    bridge-utils         # (optional) for host-defined linux bridges
  ];

  # Quality-of-life: let virt-manager auto-connect to system libvirt.
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  ##########################################
  ## Containers (choose ONE)
  ##########################################
  # A) Docker
  virtualisation.docker.enable = useDocker;

  # B) Podman
  virtualisation.podman = lib.mkIf usePodman {
    enable = true;
    dockerCompat = true;            # provides a `docker` shim for CLI muscle memory
    defaultNetwork.settings.dns_enabled = true;
  };

  # Safety net: if both are toggled, prefer Docker and disable Podman.
  assertions = [
    {
      assertion = !(useDocker && usePodman);
      message   = "Enable either Docker OR Podman — not both.";
    }
  ];

  ##########################################
  ## User group membership
  ##########################################
  users.users.${defaultUser}.extraGroups = lib.mkAfter
    ([ "kvm" "libvirtd" ] ++ lib.optionals useDocker [ "docker" ]);

  ##########################################
  ## Optional kernel tuning (harmless if present)
  ##########################################
  # Modules commonly used with KVM guests and virtio networking.
  boot.kernelModules = [
    "kvm" "kvm-intel" "kvm-amd"
    "vhost_vsock" "vhost_net"
  ];

  # Nested virtualization (only takes effect on the relevant CPU vendor).
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_amd   nested=1
  '';

  # Optional: IOMMU (PCI passthrough). Leave commented unless needed.
  # boot.kernelParams = [
  #   "amd_iommu=on" "intel_iommu=on" "iommu=pt"
  # ];
}

