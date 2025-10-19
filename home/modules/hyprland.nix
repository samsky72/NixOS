# =============================================================================
# Hyprland configuration (host-agnostic)
#
# Description:
#   Generic Hyprland setup for Home Manager. Visuals, inputs, rules, keybinds,
#   and helper tools. Host-specific bits (monitors, wallpapers) live in:
#       hosts/<host>/hm/hypr-monitors.nix
# =============================================================================
{ config, lib, pkgs, ... }:

let
  # ---------------------------------------------------------------------------
  # Helper: volume control + notification script
  # - Uses wpctl to adjust volume
  # - Sends mako-styled notification via notify-send
  # - Falls back to hyprctl notify if notify-send fails (no DBus/mako)
  # - NOTE: All shell ${...} are escaped as ''${...} to avoid Nix interpolation.
  # ---------------------------------------------------------------------------
  hyprVol = pkgs.writeShellScriptBin "hypr-vol" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    WPCTL=${pkgs.wireplumber}/bin/wpctl
    AWK=${pkgs.gawk}/bin/awk
    NOTIFY=${pkgs.libnotify}/bin/notify-send
    HYPRCTL=${pkgs.hyprland}/bin/hyprctl
    SLEEP=${pkgs.coreutils}/bin/sleep
    GREP=${pkgs.gnugrep}/bin/grep

    limit=1.25  # 125% cap (matches common UIs)

    usage() { echo "usage: hypr-vol {up|down|mute}" >&2; exit 2; }

    action="''${1:-}"
    case "''${action}" in
      up)   "''${WPCTL}" set-volume -l "''${limit}" @DEFAULT_AUDIO_SINK@ 5%+ ;;
      down) "''${WPCTL}" set-volume -l "''${limit}" @DEFAULT_AUDIO_SINK@ 5%- ;;
      mute) "''${WPCTL}" set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
      *) usage ;;
    esac

    # Let PipeWire settle so the next read is accurate
    "''${SLEEP}" 0.10

    # If muted after toggle, show a simple "Muted" toast and exit
    if [ "''${action}" = "mute" ] && "''${WPCTL}" get-volume @DEFAULT_AUDIO_SINK@ | "''${GREP}" -q MUTED; then
      "''${NOTIFY}" "🔇 Muted" 2>/dev/null || "''${HYPRCTL}" notify 3 1400 "rgb(f38ba8)" "🔇 Muted"
      exit 0
    fi

    # Compute % (normalize by the 1.25 headroom to show 0..100)
    pct="$("''${WPCTL}" get-volume @DEFAULT_AUDIO_SINK@ | "''${AWK}" -v L="''${limit}" '{print int(($2/L)*100)}')"

    case "''${action}" in
      up)
        msg="🔊 Volume: ''${pct}%"
        "''${NOTIFY}" "''${msg}" 2>/dev/null || "''${HYPRCTL}" notify -1 1400 "rgb(89b4fa)" "''${msg}"
        ;;
      down)
        msg="🔉 Volume: ''${pct}%"
        "''${NOTIFY}" "''${msg}" 2>/dev/null || "''${HYPRCTL}" notify -1 1400 "rgb(f9e2af)" "''${msg}"
        ;;
      mute)
        msg="🔊 Unmuted (''${pct}%)"
        "''${NOTIFY}" "''${msg}" 2>/dev/null || "''${HYPRCTL}" notify -1 1400 "rgb(a6e3a1)" "''${msg}"
        ;;
    esac
  '';
in
{
  ##############################################################################
  ## Core compositor setup
  ##############################################################################
  wayland.windowManager.hyprland = {
    enable = true;                  # Enable Hyprland via Home Manager
    xwayland.enable = true;         # XWayland for legacy X11 apps

    settings = {
      ######################################
      ## Input configuration
      ######################################
      input = {
        kb_layout  = "us,ru";                   # US + Russian layouts
        kb_options = "grp:win_space_toggle";    # Win+Space toggles layout
        follow_mouse = 1;                       # Focus follows cursor

        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          clickfinger_behavior = true;
          tap_button_map = "lrm";
          disable_while_typing = true;
        };
      };

      ######################################
      ## General layout and visuals
      ######################################
      general = {
        gaps_in = 6;              # Inner gaps
        gaps_out = 12;            # Outer gaps to screen edges
        border_size = 2;          # Window border thickness
        layout = "dwindle";       # Default tiling layout
      };

      ######################################
      ## Window decoration (rounding + blur)
      ######################################
      decoration = {
        rounding = 8;             # Corner radius
        blur = {
          enabled = true;
          size = 8;
          passes = 2;
        };
      };

      ######################################
      ## Animations
      ######################################
      animations = {
        enabled = true;
        bezier = [ "ease, 0.05, 0.9, 0.1, 1.05" ];
        animation = [
          "windows,    1, 7, ease"
          "workspaces, 1, 7, ease"
        ];
      };

      ######################################
      ## Miscellaneous
      ######################################
      misc = {
        force_default_wallpaper = 0;  # Don’t draw Hyprland’s default wallpaper
        focus_on_activate = true;
      };

      ######################################
      ## App-specific window rules
      ######################################
      windowrulev2 = [
        "workspace 2 silent, class:^(firefox)$"                     # Firefox → WS 2
        "workspace 4 silent, class:^(Steam|steam|steamwebhelper)$"  # Steam → WS 4
      ];

      ######################################
      ## Keybindings
      ######################################
      "$mod" = "SUPER";  # Main modifier (Super/Windows key)

      bind = [
        # --- Launchers / system actions ---
        "$mod, RETURN, exec, kitty"
        "$mod, Q, killactive,"
        "$mod, F, fullscreen, 0"
        "$mod, M, fullscreen, 1"
        "$mod, R, exec, fuzzel"
        "$mod, E, exec, thunar"
        "$mod, P, exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/shot-$(date +%s).png"
        "$mod, L, exec, loginctl lock-session"

        # --- Focus movement ---
        "$mod, LEFT,  movefocus, l"
        "$mod, RIGHT, movefocus, r"
        "$mod, UP,    movefocus, u"
        "$mod, DOWN,  movefocus, d"

        # --- Move windows (Shift+arrows) ---
        "$mod SHIFT, LEFT,  movewindow, l"
        "$mod SHIFT, RIGHT, movewindow, r"
        "$mod SHIFT, UP,    movewindow, u"
        "$mod SHIFT, DOWN,  movewindow, d"

        # --- Workspace scroll + direct jump ---
        "$mod, mouse_up,   workspace, e+1"
        "$mod, mouse_down, workspace, e-1"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"

        ##########################################
        ## Audio controls (PipeWire via wpctl)
        ## - Styled by mako via notify-send
        ## - Fallback to hyprctl notify if mako/DBus is unavailable
        ##########################################
        ", XF86AudioRaiseVolume, exec, ${hyprVol}/bin/hypr-vol up"
        ", XF86AudioLowerVolume, exec, ${hyprVol}/bin/hypr-vol down"
        ", XF86AudioMute,        exec, ${hyprVol}/bin/hypr-vol mute"
      ];

      ######################################
      ## Resize (Mod+Ctrl+Arrows)
      ######################################
      binde = [
        "$mod CTRL, LEFT,  resizeactive, -20 0"
        "$mod CTRL, RIGHT, resizeactive,  20 0"
        "$mod CTRL, UP,    resizeactive,  0 -20"
        "$mod CTRL, DOWN,  resizeactive,  0  20"
      ];

      ######################################
      ## Mouse bindings
      ######################################
      bindm = [
        "$mod, mouse:272, movewindow"   # Mod + Left mouse = move window
        "$mod, mouse:273, resizewindow" # Mod + Right mouse = resize window
      ];

      ######################################
      ## Autostart services
      ######################################
      exec-once = [
        "mako"                          # Notification daemon (themed)
        "Waybar"                        # Status bar
        "wl-paste --type text  --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];
    };

    ######################################
    ## Optional raw Hyprland config
    ######################################
    extraConfig = ''
      # Example:
      # windowrule = float,^(pavucontrol)$
    '';
  };

  ##############################################################################
  ## Helper tools and packages
  ##############################################################################
  programs.fuzzel.enable = true;  # Wayland app launcher

  home.packages = with pkgs; [
    kitty            # Terminal
    xfce.thunar      # File manager
    grim slurp       # Screenshots
    wl-clipboard     # Clipboard tools
    cliphist         # Clipboard history
    mako             # Notification daemon (themed by your Stylix/mako config)
    wireplumber      # Provides wpctl
    gawk             # awk used in inline % calc
    libnotify        # notify-send
    gnugrep          # grep used for mute detection
    coreutils        # sleep
  ];

  ##############################################################################
  ## Wayland environment variables
  ##############################################################################
  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM   = "wayland";
    NIXOS_OZONE_WL    = "1";
  };
}

