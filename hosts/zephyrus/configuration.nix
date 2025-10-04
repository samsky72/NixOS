{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/users.nix
  ];

  networking.hostName = "zephyrus";

  # Flakes + new CLI
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Basic users/groups (group name same as user)
  users.groups.samsky = { };

  users.users.samsky = {
    isNormalUser = true;
    description = "samsky";
    extraGroups = [ "wheel" "networkmanager" "samsky" ];
    # For a fresh install choose ONE of the following:
    # 1) Set a temporary password (change after first boot):
    initialPassword = "Password100";
    # 2) Or prefer an SSH authorized key:
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA... yourkey" ];
  };

  # Network basics
  networking.networkmanager.enable = true;

  # Bootloader (edit if using EFI differently)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Locale/time
  time.timeZone = "Asia/Oral";
  i18n.defaultLocale = "en_US.UTF-8";

  # For GPU/Wayland (good defaults)
  hardware.opentabletdriver.enable = lib.mkDefault false;

  # Wayland + Hyprland
  programs.hyprland.enable = true;

  # No legacy X server needed; Hyprland is Wayland-native
  services.xserver.enable = false;

  # Greeter: greetd + tuigreet (Wayland-friendly)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Portals (clipboard, file pickers, screenshare, etc.) tuned for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Wayland envs for apps
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";  # Firefox on Wayland
    NIXOS_OZONE_WL = "1";      # many Electron/Chromium apps
  };

  # System packages (keep minimal; we’ll use HM for user apps)
  environment.systemPackages = with pkgs; [
    git
  ];

  # Optional: basic services
  services.printing.enable = false;
  services.openssh.enable = true;

  # Allow unfree if you later need firmware/codecs/etc.
  nixpkgs.config.allowUnfree = true;

  # Match your current NixOS release for stable state evolution
  system.stateVersion = "24.05";
}
