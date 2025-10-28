# modules/virtualization.nix
# =============================================================================
# Virtualization: libvirt/QEMU/KVM + VirtualBox (+ optional containers)
#
# Provides
#   • libvirt daemon with QEMU/KVM, swtpm (vTPM) and virtio-fs (virtiofsd)
#   • virt-manager (GUI for libvirt) pre-enabled
#   • VirtualBox host stack (kernel module + GUI), with optional ExtPack
#   • Optional containers: choose Docker OR Podman (not both)
#
# Notes
#   • OVMF (UEFI firmware) ships with modern QEMU packages; no extra toggle.
#   • libvirt runs its own dnsmasq; a global dnsmasq install is unnecessary.
#   • VirtualBox requires membership in group `vboxusers` for USB/VRDE features.
#   • Only one container engine should be enabled to avoid conflicts.
# =============================================================================
{ pkgs, lib, defaultUser, ... }:

let
  # -----------------------------------------------------------------------------
  # Container engine selection (exactly one should be true)
  # -----------------------------------------------------------------------------
  useDocker = true;   # classic Docker engine (rootful by default on NixOS)
  usePodman = false;  # rootless Podman; provides a Docker-compatible CLI if enabled
in
{
  ##########################################
  ## libvirt + QEMU/KVM hypervisor
  ##########################################
  virtualisation.libvirtd = {
    enable = true;                 # enable libvirtd system service
    onBoot = "start";              # start at boot
    onShutdown = "shutdown";       # stop gracefully at shutdown

    qemu = {
      package = pkgs.qemu_kvm;     # QEMU with KVM acceleration enabled
      swtpm.enable = true;         # software TPM (vTPM) for Win11/BitLocker, etc.
      # virtiofsd is provided via systemPackages (below) for host/guest file sharing
      # OVMF (UEFI) firmware is shipped with QEMU in modern nixpkgs; no toggle here
    };
  };

  ##########################################
  ## VirtualBox host stack
  ##########################################
  virtualisation.virtualbox.host = {
    enable = true;                 # build and load VirtualBox host kernel module + GUI
    addNetworkInterface = true;    # create/manage vboxnet0 host-only interface
    # enableExtensionPack pulls Oracle's proprietary ExtPack:
    #   - Adds VRDE, USB 2/3, NVMe, PXE ROMs, etc.
    #   - Requires nixpkgs.config.allowUnfree = true (already set in nix.nix)
    enableExtensionPack = false;   # flip to true if the proprietary features are required
    # enableHardening remains at the upstream default (true) for security; left implicit
  };

  ##########################################
  ## GUI tooling and host helpers
  ##########################################
  programs.virt-manager.enable = true;  # virt-manager GUI for libvirt-based VMs

  # Make useful runtime tools available system-wide.
  environment.systemPackages = with pkgs; [
    virt-viewer    # SPICE/VNC viewer for libvirt guests
    spice-gtk      # SPICE client libraries for clipboard/USB redirection
    usbredir       # helper for SPICE USB redirection
    virtiofsd      # virtio-fs daemon for shared folders between host and guest
    bridge-utils   # brctl helpers, useful for custom libvirt bridges
  ];

  # Default libvirt connection for GUI tools (virt-manager/virt-viewer).
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  ##########################################
  ## Containers (choose ONE)
  ##########################################
  # A) Docker
  virtualisation.docker.enable = useDocker;

  # B) Podman (rootless by default on NixOS)
  virtualisation.podman = lib.mkIf usePodman {
    enable = true;                          # enable podman service(s)
    dockerCompat = true;                    # provide `docker` shim that maps to podman
    defaultNetwork.settings.dns_enabled = true;  # enable DNS in the default CNI network
  };

  # Ensure exactly one container engine is selected.
  assertions = [
    {
      assertion = !(useDocker && usePodman);
      message = "Enable either Docker OR Podman — not both.";
    }
  ];

  ##########################################
  ## User group membership (runtime access)
  ##########################################
  users.users.${defaultUser}.extraGroups = lib.mkAfter (
    # libvirt/KVM groups are needed to access /dev/kvm and talk to libvirtd
    [ "kvm" "libvirtd" "vboxusers" ]    # vboxusers for VirtualBox USB/VRDE
    # add docker group only when Docker is enabled
    ++ lib.optionals useDocker [ "docker" ]
  );

  ##########################################
  ## Kernel modules and nested virtualization
  ##########################################
  # Common KVM and virtio acceleration modules (safe if present).
  boot.kernelModules = [
    "kvm" "kvm-intel" "kvm-amd"  # vendor KVM modules; the irrelevant one stays inactive
    "vhost_vsock" "vhost_net"    # virtio acceleration for vsock/net
  ];

  # Allow running hypervisors inside VMs (nested virtualization) when supported.
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_amd   nested=1
  '';

  # Optional: IOMMU for PCI passthrough (leave commented unless needed).
  # boot.kernelParams = [
  #   "amd_iommu=on" "intel_iommu=on" "iommu=pt"
  # ];
}

