# modules/games.nix
# =============================================================================
# Gaming stack (Steam / Proton / Wine / utilities)
#
# Scope
#   • Enables Vulkan/OpenGL with 32-bit userspace (required by Steam/Proton)
#   • Installs Steam, GameMode, MangoHud, Wine/DXVK/VKD3D, and common launchers
#   • Adds controller udev rules
#   • Sets Wayland-first environment defaults
#
# Characteristics
#   • Host-agnostic; vendor-specific layers left optional
#   • Wayland-centric, compatible with Xwayland where needed
#   • Minimal policy: tools are present, configuration remains per-title
# =============================================================================
{ lib, pkgs, ... }:
{
  ##########################################
  ## Graphics stack (OpenGL/Vulkan + i686)
  ##########################################
  hardware.graphics = {
    enable = true;

    # Native userspace libraries
    extraPackages = with pkgs; [
      mesa
      vulkan-loader
      vulkan-validation-layers
      # Optional vendor layers (uncomment if required):
      # amdvlk
      # nvidia-vaapi-driver
    ];

    # 32-bit userspace for Steam/Proton
    extraPackages32 = with pkgs.pkgsi686Linux; [
      mesa
      vulkan-loader
    ];
  };

  ##########################################
  ## Steam (runtime default)
  ##########################################
  programs.steam = {
    enable = true;
    # The wrapped Steam runtime suits most setups.
    # To switch to the “runtime-free” package, set:
    # package = pkgs.steam;
  };

  ##########################################
  ## GameMode (on-demand performance tweaks)
  ##########################################
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        desiredgov = "performance";  # CPU governor while active
        ioprio     = 0;              # I/O priority (highest)
      };
      gpu = {
        apply_gpu_optimizations = "accept-responsibility";
      };
    };
  };

  ##########################################
  ## System packages (launchers, tooling)
  ##########################################
  environment.systemPackages = with pkgs; [
    # Launchers / stores
    heroic
    lutris

    # Proton management
    protonup-qt

    # Overlays / HUD
    mangohud
    goverlay

    # Wine toolchain (for Lutris / non-Steam titles)
    wineWowPackages.staging     # 32/64-bit Wine (staging)
    winetricks
    dxvk
    vkd3d

    # Controllers / HID
    game-devices-udev-rules
    # antimicrox  # gamepad-to-keyboard mapper (optional)
  ];

  ##########################################
  ## Controller / HID rules
  ##########################################
  services.udev.packages = [ pkgs.game-devices-udev-rules ];

  ##########################################
  ## Wayland-friendly defaults for games
  ##########################################
  environment.sessionVariables = {
    # Prefer Wayland backends where available
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL  = "1";

    # MangoHud enabled by default (toggle in-game as configured by MangoHud)
    MANGOHUD = "1";

    # GameMode is invoked automatically by supported launchers.
    # For others, prefix commands with: gamemoderun
  };

  ##########################################
  ## Optional: Steam Remote Play / Steam Link
  ##########################################
  # networking.firewall.allowedUDPPorts = [ 27031 27036 ];
  # networking.firewall.allowedTCPPorts = [ 27036 27037 ];

  ##########################################
  ## Optional: non-free firmware/drivers
  ##########################################
  # nixpkgs.config.allowUnfree = true;

  ##########################################
  ## Notes
  ## • NVIDIA requires the proprietary driver module and modesetting.
  ## • AMD/Intel typically work with Mesa; recent kernel/firmware is beneficial.
  ## • Per-title MangoHud config: ~/.config/MangoHud/MangoHud.conf
  ## • Proton GE: install via ProtonUp-Qt, then select per title in Steam.
  ##########################################
}

