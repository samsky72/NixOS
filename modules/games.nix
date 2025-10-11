# modules/games.nix
{ lib, pkgs, ... }:
{
  ##########################################
  ## Gaming stack (Steam / Proton / Wine / Tools)
  ##########################################

  #### Graphics stack (OpenGL/Vulkan + 32-bit userspace for Steam/Proton)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa.drivers
      vulkan-loader
      vulkan-validation-layers
      # Optional: vendor-specific layers (uncomment as needed)
      # amdvlk
      # nvidia-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      mesa
      vulkan-loader
    ];
  };

  #### Game launchers / runtimes
  programs.steam = {
    enable = true;
    # Some people prefer Steam's runtime wrapped; leave default unless you need runtime-free
    # package = pkgs.steam; 
    # Remote Play / In-Home Streaming can need extra firewall rules; see bottom.
  };

  # Feral GameMode: temporary performance tweaks while gaming
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        desiredgov = "performance";
        ioprio = 0;
      };
      gpu = {
        apply_gpu_optimizations = "accept-responsibility";
      };
    };
  };


  #### Helpful system packages for gaming
  environment.systemPackages = with pkgs; [
    # Launchers/Stores
    heroic
    lutris

    # Proton management
    protonup-qt

    mangohud

    # Wine toolchain & translations (for Lutris/non-Steam)
    wineWowPackages.staging  # 32/64-bit Wine (staging build)
    winetricks
    dxvk
    vkd3d

    # Overlays & config tools
    goverlay

    # Controllers / utils
    game-devices-udev-rules
    # (Optional) antimicrox  # gamepad-to-keyboard mapper
  ];

  #### Controller / HID rules
  # Adds udev rules for a wide range of game controllers (DualShock/Xbox/etc.)
  services.udev.packages = [ pkgs.game-devices-udev-rules ];

  #### Wayland-friendly defaults for games
  environment.sessionVariables = {
    # Prefer Wayland where possible (SDL/Qt/Electron)
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";

    # MangoHud default toggle (use ctrl+f12 in-game to show/hide)
    MANGOHUD = "1";

    # GameMode: auto start for supported launchers; for others, prefix with `gamemoderun`
    # Example in Steam launch options: gamemoderun %command%
  };

  #### Optional: Steam Remote Play / Steam Link ports
  # networking.firewall.allowedUDPPorts = [ 27031 27036 ];
  # networking.firewall.allowedTCPPorts = [ 27036 27037 ];

  #### Optional: allow non-free firmware/drivers (usually already enabled elsewhere)
  # nixpkgs.config.allowUnfree = true;

  ##########################################
  ## Notes
  ## - For NVIDIA: add nvidia drivers + enable modesetting in your GPU module.
  ## - For AMD/Intel: Mesa above is usually enough; ensure your kernel/firmware are recent.
  ## - Per-game MangoHud config: ~/.config/MangoHud/MangoHud.conf
  ## - Proton GE: install via ProtonUp-Qt, then select in Steam per title.
  ##########################################
}

