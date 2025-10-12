# home/modules/hyprland.nix
{ config, lib, pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      ##########################################
      ## Monitors — by DESCRIPTION, scale = 1.0
      ## (Replace descriptions with exact strings from `hyprctl monitors`)
      ##########################################
      monitor = [
        "desc:BOE NE160QDM-NM4, 2560x1600@240, 640x0, 1.0"  # laptop (top)
        "desc:BOE 0x0A68,      3840x1100@60,  0x1600, 1.0"  # external (bottom)
      ];

      ##########################################
      ## Input
      ##########################################
      input = {
        kb_layout  = "us,ru";
        kb_options = "grp:win_space_toggle";
        follow_mouse = 1;

        touchpad = {
          natural_scroll = true;
          tap-to-click = true;        # correct key
          clickfinger_behavior = true;
          tap_button_map = "lrm";
          disable_while_typing = true;
        };
      };

      ##########################################
      ## Appearance & behavior
      ##########################################
      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 8;
          passes = 2;
        };
      };

      animations = {
        enabled = true;
        bezier = [ "ease, 0.05, 0.9, 0.1, 1.05" ];
        animation = [
          "windows, 1, 7, ease"
          "workspaces, 1, 7, ease"
        ];
      };

      misc = {
        force_default_wallpaper = 0;
        focus_on_activate = true;
      };

      ##########################################
      ## Persistent workspaces bound by DESCRIPTION
      ## 1,2 → laptop; 3,4 → external
      ##########################################
      workspace = [
        "1, monitor:desc:BOE NE160QDM-NM4, persistent:true, default:true"
        "2, monitor:desc:BOE NE160QDM-NM4, persistent:true"
        "3, monitor:desc:BOE 0x0A68,      persistent:true, default:true"
        "4, monitor:desc:BOE 0x0A68,      persistent:true"
      ];

      ##########################################
      ## Window rules — app-to-workspace placement
      ##########################################
      windowrulev2 = [
        # Firefox → workspace 2
        "workspace 2 silent, class:^(firefox)$"

        # Steam → workspace 4 (cover helpers too)
        "workspace 4 silent, class:^(Steam|steam|steamwebhelper)$"
      ];

      ##########################################
      ## Keybindings
      ##########################################
      "$mod" = "SUPER";

      bind = [
        # Launchers / actions
        "$mod, RETURN, exec, kitty"
        "$mod, Q, killactive,"
        "$mod, F, fullscreen, 0"          # true fullscreen
        "$mod, M, fullscreen, 1"          # ← maximize-style (fake fullscreen)
        "$mod, R, exec, fuzzel"
        "$mod, E, exec, thunar"
        "$mod, P, exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/shot-$(date +%s).png"
        "$mod, L, exec, loginctl lock-session"

        # Focus by arrows
        "$mod, LEFT,  movefocus, l"
        "$mod, RIGHT, movefocus, r"
        "$mod, UP,    movefocus, u"
        "$mod, DOWN,  movefocus, d"

        # Move windows (Shift+arrows)
        "$mod SHIFT, LEFT,  movewindow, l"
        "$mod SHIFT, RIGHT, movewindow, r"
        "$mod SHIFT, UP,    movewindow, u"
        "$mod SHIFT, DOWN,  movewindow, d"

        # Workspace scroll
        "$mod, mouse_up,   workspace, e+1"
        "$mod, mouse_down, workspace, e-1"

        # Jump to workspace 1–4
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"

        # Move window to workspace 1–4
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
      ];

      # Resize with Mod+Ctrl+arrows (continuous)
      binde = [
        "$mod CTRL, LEFT,  resizeactive, -20 0"
        "$mod CTRL, RIGHT, resizeactive,  20 0"
        "$mod CTRL, UP,    resizeactive,  0 -20"
        "$mod CTRL, DOWN,  resizeactive,  0  20"
      ];

      # Mouse binds
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      ##########################################
      ## Autostart
      ##########################################
      exec-once = [
        "Waybar"
        "hyprpaper"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];
    };

    extraConfig = ''
      # Example:
      # windowrule = float,^(pavucontrol)$
    '';
  };

  ##########################################
  ## Wallpaper (hyprpaper) — by DESCRIPTION
  ##########################################
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

  ##########################################
  ## Helpers
  ##########################################
  programs.fuzzel.enable = true;
  home.packages = with pkgs; [ kitty xfce.thunar grim slurp wl-clipboard cliphist ];

  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";
  };
}

