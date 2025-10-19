# hosts/zephyrus/hm/hypr-monitors.nix
# =============================================================================
# Hyprland – host-specific configuration for Zephyrus
#
# Description:
#   • Defines monitor layout and workspace mapping
#   • Configures per-monitor wallpapers via Hyprpaper
#   • Adds brightness controls for both main and secondary displays
#
# Notes:
#   • The main display uses dynamic detection for amdgpu_bl* devices
#   • The ScreenPad+ uses the fixed `asus_screenpad` backlight device
#   • Uses numeric keycodes (233/232) for brightness events
#   • Each bind is a single, parser-safe command using bash -c
# =============================================================================
{ config, pkgs, ... }:

{
  ##############################################################################
  ## Display configuration
  ##############################################################################
  wayland.windowManager.hyprland.settings = {
    ##########################################
    ## Monitor layout (identified by description)
    ##########################################
    monitor = [
      "desc:BOE NE160QDM-NM4, 2560x1600@240, 640x0, 1.0"  # Primary (top display)
      "desc:BOE 0x0A68,      3840x1100@60,  0x1600, 1.0"  # Secondary (bottom display)
    ];

    ##########################################
    ## Workspace mapping per monitor
    ##########################################
    workspace = [
      "1, monitor:desc:BOE NE160QDM-NM4, persistent:true, default:true"
      "2, monitor:desc:BOE NE160QDM-NM4, persistent:true"
      "3, monitor:desc:BOE 0x0A68,      persistent:true, default:true"
      "4, monitor:desc:BOE 0x0A68,      persistent:true"
    ];

    ##########################################
    ## Brightness control (per display)
    ##
    ## Keycodes from `wev`:
    ##   233 → Brightness Up
    ##   232 → Brightness Down
    ##
    ## The CTRL modifier is used since Fn+Win disables the Super key
    ## on some ASUS firmware implementations.
    ##########################################
    bind = [
      # --- Primary display (auto-detect amdgpu_bl device) ---
      ", 233, exec, bash -c 'dev=$(ls /sys/class/backlight | grep amdgpu_bl | head -n1); [ -n \"$dev\" ] && brightnessctl -d $dev set +10% && notify-send \"🌞 Main display: $(brightnessctl -d $dev g | awk -v max=$(brightnessctl -d $dev m) \"{printf \\\"%d%%\\\", (\$1/max)*100}\")\" || notify-send \"⚠️ No AMD backlight device detected\"'"
      ", 232, exec, bash -c 'dev=$(ls /sys/class/backlight | grep amdgpu_bl | head -n1); [ -n \"$dev\" ] && brightnessctl -d $dev set 10%- && notify-send \"🌙 Main display: $(brightnessctl -d $dev g | awk -v max=$(brightnessctl -d $dev m) \"{printf \\\"%d%%\\\", (\$1/max)*100}\")\" || notify-send \"⚠️ No AMD backlight device detected\"'"

      # --- ScreenPad+ (explicit device) ---
      "CTRL, 233, exec, bash -c 'brightnessctl -d asus_screenpad set +10% && notify-send \"🌞 ScreenPad+: $(brightnessctl -d asus_screenpad g | awk -v max=$(brightnessctl -d asus_screenpad m) \"{printf \\\"%d%%\\\", (\$1/max)*100}\")\"'"
      "CTRL, 232, exec, bash -c 'brightnessctl -d asus_screenpad set 10%- && notify-send \"🌙 ScreenPad+: $(brightnessctl -d asus_screenpad g | awk -v max=$(brightnessctl -d asus_screenpad m) \"{printf \\\"%d%%\\\", (\$1/max)*100}\")\"'"
    ];
  };

  ##############################################################################
  ## Wallpaper configuration (Hyprpaper)
  ##############################################################################
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "${config.home.homeDirectory}/.local/share/wallpapers/wall.jpg"
      ];
      wallpaper = [
        "desc:BOE NE160QDM-NM4,${config.home.homeDirectory}/.local/share/wallpapers/wall.jpg"
        "desc:BOE 0x0A68,${config.home.homeDirectory}/.local/share/wallpapers/wall.jpg"
      ];
      ipc = true;
    };
  };

  ##############################################################################
  ## Required packages
  ##############################################################################
  home.packages = with pkgs; [ brightnessctl libnotify ];
}

