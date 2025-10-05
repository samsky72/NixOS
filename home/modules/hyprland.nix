{ config, lib, pkgs, ... }:
{
  ##########################################
  ## Hyprland (user-level configuration)
  ##########################################
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      ##########################################
      ## Monitors — layout by description
      ##########################################
      monitor = [
        # Built-in laptop display (top)
        "desc:BOE NE160QDM-NM4, 2560x1600@240, 640x0, 1.6"

        # External display (bottom)
        "desc:BOE 0x0A68, 3840x1100@60, 0x1600, 2.0"
      ];

      ##########################################
      ## Input
      ##########################################
      input = {
        kb_layout = "us,ru";
        kb_options = "grp:win_space_toggle";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
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
      ## Keybindings — arrow-key driven
      ##########################################
      "$mod" = "SUPER";

      bind = [
        # --- Launch / actions ---
        "$mod, RETURN, exec, kitty"
        "$mod, Q, killactive,"
        "$mod, F, fullscreen, 0"
        "$mod, R, exec, fuzzel"
        "$mod, E, exec, thunar"
        "$mod, P, exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/shot-$(date +%s).png"
        "$mod, L, exec, loginctl lock-session"

        # --- Focus movement (arrow keys) ---
        "$mod, LEFT,  movefocus, l"
        "$mod, RIGHT, movefocus, r"
        "$mod, UP,    movefocus, u"
        "$mod, DOWN,  movefocus, d"

        # --- Move windows (Mod+Shift + arrows) ---
        "$mod SHIFT, LEFT,  movewindow, l"
        "$mod SHIFT, RIGHT, movewindow, r"
        "$mod SHIFT, UP,    movewindow, u"
        "$mod SHIFT, DOWN,  movewindow, d"

        # --- Workspace scrolling with mouse wheel ---
        "$mod, mouse_up,   workspace, e+1"
        "$mod, mouse_down, workspace, e-1"
      ];

      # --- Resize windows (Mod+Ctrl + arrows, continuous) ---
      binde = [
        "$mod CTRL, LEFT,  resizeactive, -20 0"
        "$mod CTRL, RIGHT, resizeactive,  20 0"
        "$mod CTRL, UP,    resizeactive,  0 -20"
        "$mod CTRL, DOWN,  resizeactive,  0  20"
      ];

      # --- Mouse bindings ---
      bindm = [
        "$mod, mouse:272, movewindow"   # Mod + LMB → move window
        "$mod, mouse:273, resizewindow" # Mod + RMB → resize window
      ];

      ##########################################
      ## Autostart (minimal, no Waybar/applets)
      ##########################################
      exec-once = [
        "hyprpaper"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];
    };

    extraConfig = ''
      # Example extra rules:
      # windowrule = float,^(pavucontrol)$
    '';
  };

  ##########################################
  ## Wallpaper (hyprpaper)
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
  ## Utilities & Wayland helpers
  ##########################################
  programs.fuzzel.enable = true; # app launcher

  home.packages = with pkgs; [
    kitty
    xfce.thunar
    grim
    slurp
    wl-clipboard
    cliphist
  ];

  ##########################################
  ## Environment variables for Wayland
  ##########################################
  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";
  };
}
