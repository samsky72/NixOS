# home/modules/hyprland.nix
# =============================================================================
# Hyprland (Home Manager)
#
# Provides:
#   • Hyprland config (Wayland compositor) with XWayland enabled
#   • Helper scripts:
#       - hypr-vol   : volume control + notifications (PipeWire/wpctl)
#       - hypr-kbdbl : keyboard backlight cycle/off using brightnessctl
#   • Keybindings for common actions, audio, and keyboard backlight
#   • Supporting user packages and Wayland-friendly environment variables
#
# Design:
#   • Host-agnostic; no hardware identifiers baked in
#   • Notification preference: libnotify (mako) → Hyprland fallback
#   • Shell variable expansion inside Nix strings escaped as ''${...}
# =============================================================================
{ config, lib, pkgs, ... }:

let
  # ---------------------------------------------------------------------------
  # hypr-vol: Volume helper (PipeWire/wpctl + notification)
  #
  # Inputs:
  #   • @DEFAULT_AUDIO_SINK@     : PipeWire default sink (implicit)
  #   • limit=1.25               : headroom cap (125%) for wpctl
  #
  # Behavior:
  #   • "up" / "down" increments/decrements by 5%
  #   • "mute" toggles mute state
  #   • Notification path: notify-send (mako/libnotify) → hyprctl notify fallback
  #
  # Tools (absolute paths):
  #   • ${pkgs.wireplumber}/bin/wpctl   : PipeWire control CLI
  #   • ${pkgs.libnotify}/bin/notify-send : desktop notifications
  #   • ${pkgs.hyprland}/bin/hyprctl   : fallback notification
  #   • ${pkgs.gawk}/bin/awk           : percentage math
  #   • ${pkgs.coreutils}/bin/sleep    : small stabilization delay
  #   • ${pkgs.gnugrep}/bin/grep       : mute detection
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

    limit=1.25

    usage() { echo "usage: hypr-vol {up|down|mute}" >&2; exit 2; }

    action="''${1:-}"
    case "''${action}" in
      up)   "''${WPCTL}" set-volume -l "''${limit}" @DEFAULT_AUDIO_SINK@ 5%+ ;;
      down) "''${WPCTL}" set-volume -l "''${limit}" @DEFAULT_AUDIO_SINK@ 5%- ;;
      mute) "''${WPCTL}" set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
      *) usage ;;
    esac

    "''${SLEEP}" 0.10

    if [ "''${action}" = "mute" ] && "''${WPCTL}" get-volume @DEFAULT_AUDIO_SINK@ | "''${GREP}" -q MUTED; then
      "''${NOTIFY}" "🔇 Muted" 2>/dev/null || "''${HYPRCTL}" notify 3 1400 "rgb(f38ba8)" "🔇 Muted"
      exit 0
    fi

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

  # ---------------------------------------------------------------------------
  # hypr-kbdbl: Keyboard backlight helper (cycle → off)
  #
  # Inputs:
  #   • brightnessctl device list: finds first *::kbd_backlight in Device lines
  #
  # Behavior (mode=cycle):
  #   • If current brightness < max → step +1
  #   • If current brightness == max → set 0 (off)
  #   • If no device is found → exit silently
  #
  # Tools (absolute paths):
  #   • ${pkgs.brightnessctl}/bin/brightnessctl : kbd backlight control
  #   • ${pkgs.gawk}/bin/awk                     : device extraction
  #   • ${pkgs.coreutils}/bin/true              : graceful pipeline fallback
  #
  # Keybinds:
  #   • Map to the hardware keysym: XF86KbdLightOnOff
  # ---------------------------------------------------------------------------
  hyprKbdbl = pkgs.writeShellScriptBin "hypr-kbdbl" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    BCTL=${pkgs.brightnessctl}/bin/brightnessctl
    AWK=${pkgs.gawk}/bin/awk
    TRUE=${pkgs.coreutils}/bin/true

    mode="''${1:-cycle}"

    # Extract first device whose name ends with ::kbd_backlight from Device lines.
    # Example line: Device 'asus::kbd_backlight' of class 'leds':
    dev=$("''${BCTL}" -l \
      | "''${AWK}" -F"'" '/::kbd_backlight/ {print $2; exit}' \
      || "''${TRUE}")

    # Fallback paths (broader match) if none found:
    if [ -z "''${dev}" ]; then
      dev=$("''${BCTL}" -l \
        | "''${AWK}" -F"'" '/kbd_backlight/ {print $2; exit}' \
        || "''${TRUE}")
    fi

    # Exit quietly if no device is available.
    [ -z "''${dev}" ] && exit 0

    case "''${mode}" in
      cycle)
        cur=$("''${BCTL}" -d "''${dev}" g)  # current brightness (integer)
        max=$("''${BCTL}" -d "''${dev}" m)  # max brightness (integer)
        if [ "''${cur}" -lt "''${max}" ]; then
          exec "''${BCTL}" -d "''${dev}" set +1
        else
          exec "''${BCTL}" -d "''${dev}" set 0
        fi
        ;;
      off)
        exec "''${BCTL}" -d "''${dev}" set 0
        ;;
      *)
        echo "usage: hypr-kbdbl {cycle|off}" >&2
        exit 2
        ;;
    esac
  '';
in
{
  # ===========================================================================
  # Hyprland enablement and primary settings
  # ===========================================================================
  wayland.windowManager.hyprland = {
    enable = true;          # enable Hyprland management via Home Manager
    xwayland.enable = true; # enable XWayland for legacy X11 applications

    settings = {
      # ------------------------------------------------------------------------
      # Input configuration
      # ------------------------------------------------------------------------
      input = {
        kb_layout  = "us,ru";                   # keyboard layouts: US, RU
        kb_options = "grp:win_space_toggle";    # layout toggle: Super+Space
        follow_mouse = 1;                       # focus follows mouse cursor

        touchpad = {
          natural_scroll = true;                # touch-like scrolling direction
          tap-to-click = true;                  # enable tap gestures as clicks
          clickfinger_behavior = true;          # multi-finger click behavior
          tap_button_map = "lrm";               # tap mapping: left/right/middle
          disable_while_typing = true;          # avoid accidental cursor moves
        };
      };

      # ------------------------------------------------------------------------
      # General layout and visuals
      # ------------------------------------------------------------------------
      general = {
        gaps_in = 6;               # inner gaps between client windows (px)
        gaps_out = 12;             # outer gaps to screen edges (px)
        border_size = 2;           # window border thickness (px)
        layout = "dwindle";        # tiling layout algorithm
      };

      # ------------------------------------------------------------------------
      # Decorations (rounding + blur)
      # ------------------------------------------------------------------------
      decoration = {
        rounding = 8;              # window corner radius (px)
        blur = {
          enabled = true;          # enable background blur
          size = 8;                # blur kernel size
          passes = 2;              # blur passes (quality/perf tradeoff)
        };
      };

      # ------------------------------------------------------------------------
      # Animations (cohesive easing and durations)
      # ------------------------------------------------------------------------
      animations = {
        enabled = true;                                     # master switch
        bezier = [ "ease, 0.05, 0.9, 0.1, 1.05" ];          # cubic-bezier curve
        animation = [
          "windows,    1, 7, ease"                          # window animation
          "workspaces, 1, 7, ease"                          # workspace animation
        ];
      };

      # ------------------------------------------------------------------------
      # Miscellaneous compositor behavior
      # ------------------------------------------------------------------------
      misc = {
        force_default_wallpaper = 0;  # disable Hyprland default wallpaper
        focus_on_activate = true;     # focus windows when they activate
      };

      # ------------------------------------------------------------------------
      # Window rules (class-based routing)
      # ------------------------------------------------------------------------
      windowrulev2 = [
        "workspace 2 silent, class:^(firefox)$"                     # Firefox → WS 2
        "workspace 4 silent, class:^(Steam|steam|steamwebhelper)$"  # Steam  → WS 4
      ];

      # ------------------------------------------------------------------------
      # Keybindings
      #   $mod = SUPER (Windows key)
      #   All commands use either Hyprland dispatchers or exec for external tools
      # ------------------------------------------------------------------------
      "$mod" = "SUPER";  # Hyprland variable used in following bindings

      bind = [
        # --- Launchers / system actions ---------------------------------------
        "$mod, RETURN, exec, kitty"                                                   # launch terminal
        "$mod, Q,      killactive,"                                                   # close focused window
        "$mod, F,      fullscreen, 0"                                                 # true fullscreen toggle
        "$mod, M,      fullscreen, 1"                                                 # maximize/pseudo-fullscreen
        "$mod, R,      exec, fuzzel"                                                  # app launcher
        "$mod, E,      exec, thunar"                                                  # file manager
        "$mod, P,      exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/shot-$(date +%s).png" # region screenshot
        "$mod, L,      exec, loginctl lock-session"                                   # lock session

        # --- Focus movement ----------------------------------------------------
        "$mod, LEFT,   movefocus, l"                                                  # focus left
        "$mod, RIGHT,  movefocus, r"                                                  # focus right
        "$mod, UP,     movefocus, u"                                                  # focus up
        "$mod, DOWN,   movefocus, d"                                                  # focus down

        # --- Move windows ------------------------------------------------------
        "$mod SHIFT, LEFT,  movewindow, l"                                            # move window left
        "$mod SHIFT, RIGHT, movewindow, r"                                            # move window right
        "$mod SHIFT, UP,    movewindow, u"                                            # move window up
        "$mod SHIFT, DOWN,  movewindow, d"                                            # move window down

        # --- Workspaces (scroll + specific) -----------------------------------
        "$mod, mouse_up,   workspace, e+1"                                            # next workspace
        "$mod, mouse_down, workspace, e-1"                                            # previous workspace
        "$mod, 1, workspace, 1"                                                       # goto WS 1
        "$mod, 2, workspace, 2"                                                       # goto WS 2
        "$mod, 3, workspace, 3"                                                       # goto WS 3
        "$mod, 4, workspace, 4"                                                       # goto WS 4
        "$mod SHIFT, 1, movetoworkspace, 1"                                           # move window → WS 1
        "$mod SHIFT, 2, movetoworkspace, 2"                                           # move window → WS 2
        "$mod SHIFT, 3, movetoworkspace, 3"                                           # move window → WS 3
        "$mod SHIFT, 4, movetoworkspace, 4"                                           # move window → WS 4

        # --- Audio controls (PipeWire/wpctl via hypr-vol) ---------------------
        ", XF86AudioRaiseVolume, exec, ${hyprVol}/bin/hypr-vol up"                    # hardware vol up
        ", XF86AudioLowerVolume, exec, ${hyprVol}/bin/hypr-vol down"                  # hardware vol down
        ", XF86AudioMute,        exec, ${hyprVol}/bin/hypr-vol mute"                  # hardware mute

        # --- Keyboard backlight (hardware keysym from xev/wev) ----------------
        #     Uses a single key to cycle brightness upward and wrap to OFF.
        ", XF86KbdLightOnOff,    exec, ${hyprKbdbl}/bin/hypr-kbdbl cycle"             # kbd backlight cycle→off
      ];

      # ------------------------------------------------------------------------
      # Resize bindings (continuous; Mod+Ctrl+Arrows)
      # ------------------------------------------------------------------------
      binde = [
        "$mod CTRL, LEFT,  resizeactive, -20 0"   # shrink horizontally
        "$mod CTRL, RIGHT, resizeactive,  20 0"   # grow   horizontally
        "$mod CTRL, UP,    resizeactive,  0 -20"  # shrink vertically
        "$mod CTRL, DOWN,  resizeactive,  0  20"  # grow   vertically
      ];

      # ------------------------------------------------------------------------
      # Mouse bindings (button codes: 272=left, 273=right)
      # ------------------------------------------------------------------------
      bindm = [
        "$mod, mouse:272, movewindow"   # Mod + Left  : drag to move window
        "$mod, mouse:273, resizewindow" # Mod + Right : drag to resize window
      ];

      # ------------------------------------------------------------------------
      # Autostart processes (once per session)
      # ------------------------------------------------------------------------
      exec-once = [
        "mako"                           # notification daemon (libnotify consumer)
        "Waybar"                         # status bar
        "wl-paste --type text  --watch cliphist store"   # text clipboard history
        "wl-paste --type image --watch cliphist store"   # image clipboard history
      ];
    };

    # --------------------------------------------------------------------------
    # Extra Hyprland config (raw text; optional)
    # --------------------------------------------------------------------------
    extraConfig = ''
      # Example:
      # windowrule = float,^(pavucontrol)$
    '';
  };

  # ===========================================================================
  # Companion packages (installed in the user profile)
  # ===========================================================================
  programs.fuzzel.enable = true;  # Wayland app launcher (invoked by $mod+R)

  home.packages = with pkgs; [
    kitty            # terminal emulator used by "$mod, RETURN, exec, kitty"
    xfce.thunar      # file manager used by "$mod, E, exec, thunar"
    grim             # screenshot tool used in region capture binding
    slurp            # region selector used with grim in screenshot binding
    wl-clipboard     # Wayland clipboard utilities (wl-copy/wl-paste) for cliphist
    cliphist         # clipboard history backend consumed by wl-paste --watch
    mako             # notification daemon that handles libnotify toasts
    wireplumber      # PipeWire session manager that provides wpctl
    gawk             # awk used inside helper scripts for parsing/math
    libnotify        # notify-send used by hypr-vol for toasts
    gnugrep          # grep used by hypr-vol to detect MUTED state
    coreutils        # sleep, true, and other basic tools used in scripts
    brightnessctl    # keyboard backlight control used by hypr-kbdbl
  ];

  # ===========================================================================
  # Wayland-friendly environment variables
  # ===========================================================================
  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";  # declare session type for toolkits
    MOZ_ENABLE_WAYLAND = "1";      # prefer Wayland backend in Firefox
    QT_QPA_PLATFORM   = "wayland"; # prefer Wayland backend in Qt apps
    NIXOS_OZONE_WL    = "1";       # enable Wayland path for Chromium/Electron
  };
}

