# =============================================================================
# Hyprland configuration (host-agnostic)
#
# Description:
#   Generic Hyprland setup for Home Manager. Handles visuals, inputs, rules,
#   keybinds, and helper tools. Host-specific bits (monitors, wallpapers) live in:
#       hosts/<host>/hm/hypr-monitors.nix
#
# Design notes:
#   • Home Manager module only; avoids hardware assumptions.
#   • XWayland is enabled for legacy applications.
#   • Notifications prefer libnotify/mako; gracefully fall back to hyprctl’s
#     built-in notifier when DBus or a notification daemon is unavailable.
#   • All shell interpolation inside Nix strings uses ''${…} to prevent
#     evaluation by the Nix interpreter.
# =============================================================================
{ config, lib, pkgs, ... }:

let
  # ---------------------------------------------------------------------------
  # Helper: hypr-vol (volume control + notification)
  #
  # Purpose
  #   • Adjusts the default PipeWire sink volume or mute state via `wpctl`
  #   • Shows a toast using `notify-send` (mako/libnotify) when available
  #   • Falls back to `hyprctl notify` if notifications are not available
  #
  # Behavior
  #   • Headroom: sets a 1.25 (125%) limiter for `wpctl set-volume -l …`
  #   • Readback: sleeps briefly so `wpctl get-volume` reflects the new level
  #   • Normalization: divides the raw level by 1.25 so the displayed % is 0–100
  #
  # Compatibility
  #   • No assumptions about audio device names (uses @DEFAULT_AUDIO_SINK@)
  #   • Runs as an isolated script (keeps Hyprland config lines simple)
  #
  # Implementation notes
  #   • The script references tool paths via pkgs to avoid “tool not found” issues.
  #   • All occurrences of ${…} inside the shell body are escaped as ''${…}
  #     to avoid Nix expanding them at evaluation time.
  # ---------------------------------------------------------------------------
  hyprVol = pkgs.writeShellScriptBin "hypr-vol" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    # --- Tooling (absolute paths for reliability) -----------------------------
    WPCTL=${pkgs.wireplumber}/bin/wpctl        # PipeWire control CLI
    AWK=${pkgs.gawk}/bin/awk                   # used for numeric normalization
    NOTIFY=${pkgs.libnotify}/bin/notify-send   # libnotify frontend (mako picks this up)
    HYPRCTL=${pkgs.hyprland}/bin/hyprctl       # fallback notifier
    SLEEP=${pkgs.coreutils}/bin/sleep          # small delay to let PipeWire settle
    GREP=${pkgs.gnugrep}/bin/grep              # used to detect "MUTED" state

    # --- Parameters -----------------------------------------------------------
    limit=1.25  # cap (125%) to allow gentle headroom without clipping

    usage() { echo "usage: hypr-vol {up|down|mute}" >&2; exit 2; }

    # --- Dispatch -------------------------------------------------------------
    action="''${1:-}"
    case "''${action}" in
      up)   "''${WPCTL}" set-volume -l "''${limit}" @DEFAULT_AUDIO_SINK@ 5%+ ;;
      down) "''${WPCTL}" set-volume -l "''${limit}" @DEFAULT_AUDIO_SINK@ 5%- ;;
      mute) "''${WPCTL}" set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
      *) usage ;;
    esac

    # Allow the graph to settle so the readback is accurate.
    "''${SLEEP}" 0.10

    # If a mute toggle just occurred and the sink is muted, show a simple toast.
    if [ "''${action}" = "mute" ] && "''${WPCTL}" get-volume @DEFAULT_AUDIO_SINK@ | "''${GREP}" -q MUTED; then
      "''${NOTIFY}" "🔇 Muted" 2>/dev/null || "''${HYPRCTL}" notify 3 1400 "rgb(f38ba8)" "🔇 Muted"
      exit 0
    fi

    # Compute an integer percentage normalized to 0–100 (dividing by the headroom).
    pct="$("''${WPCTL}" get-volume @DEFAULT_AUDIO_SINK@ | "''${AWK}" -v L="''${limit}" '{print int(($2/L)*100)}')"

    # Compose message + color hint; prefer libnotify/mako; fallback to hyprctl.
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
  ##
  ## Notes:
  ##   • `enable = true` ensures the HM-managed Hyprland config is generated.
  ##   • `xwayland.enable = true` retains compatibility with X11-only apps.
  ##############################################################################
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      ######################################
      ## Input configuration
      ##
      ## Keyboard: dual layout with a single key chord to switch (Win+Space).
      ## Touchpad: common laptop gestures + tap-to-click ergonomics.
      ######################################
      input = {
        kb_layout  = "us,ru";                   # two layouts: US + Russian
        kb_options = "grp:win_space_toggle";    # quick toggle with Win+Space
        follow_mouse = 1;                       # focus follows cursor; adjust per taste

        touchpad = {
          natural_scroll = true;                # two-finger scroll matches touch UIs
          tap-to-click = true;                  # light taps register as clicks
          clickfinger_behavior = true;          # number of fingers decides button
          tap_button_map = "lrm";               # tap mapping: left/right/middle
          disable_while_typing = true;          # avoids accidental cursor jumps
        };
      };

      ######################################
      ## General layout and visuals
      ##
      ## Dwindle offers compact tiling. Borders and gaps are kept moderate to
      ## balance information density and visual separation.
      ######################################
      general = {
        gaps_in = 6;              # inner gaps between client windows
        gaps_out = 12;            # outer gaps to screen edges
        border_size = 2;          # window border thickness (px)
        layout = "dwindle";       # default tiling layout (spiral/stack hybrid)
      };

      ######################################
      ## Window decoration (rounding + blur)
      ##
      ## Blur passes increase cost; two passes with a small kernel is a
      ## reasonable balance for mid/high-end GPUs.
      ######################################
      decoration = {
        rounding = 8;             # corner radius (px)
        blur = {
          enabled = true;
          size = 8;               # kernel size; increase for stronger blur
          passes = 2;             # render passes; more = smoother + costlier
        };
      };

      ######################################
      ## Animations
      ##
      ## A single cubic-bezier curve keeps motion cohesive across windows and
      ## workspaces. Durations use Hyprland’s arbitrary units (1,7 here).
      ######################################
      animations = {
        enabled = true;
        bezier = [ "ease, 0.05, 0.9, 0.1, 1.05" ];
        animation = [
          "windows,    1, 7, ease"   # open/close/min/max transitions
          "workspaces, 1, 7, ease"   # workspace change transitions
        ];
      };

      ######################################
      ## Miscellaneous
      ##
      ## Wallpaper drawing is delegated to hyprpaper; disable Hyprland’s default.
      ## focus_on_activate ensures new client activation is respected.
      ######################################
      misc = {
        force_default_wallpaper = 0;  # do not draw Hyprland’s default wallpaper
        focus_on_activate = true;     # focus newly activated windows
      };

      ######################################
      ## App-specific window rules
      ##
      ## Regex anchors (^) guard against accidental matches.
      ######################################
      windowrulev2 = [
        "workspace 2 silent, class:^(firefox)$"                     # Firefox → WS2
        "workspace 4 silent, class:^(Steam|steam|steamwebhelper)$"  # Steam → WS4
      ];

      ######################################
      ## Keybindings
      ##
      ## Conventions:
      ##   • $mod = SUPER (Windows key)
      ##   • FIRST group: launchers/system actions
      ##   • SECOND group: focus & movement
      ##   • THIRD group: workspaces
      ##   • FOURTH group: audio controls (via hypr-vol helper)
      ######################################
      "$mod" = "SUPER";

      bind = [
        # --- Launchers / system actions ---------------------------------------
        "$mod, RETURN, exec, kitty"                                                   # terminal
        "$mod, Q,      killactive,"                                                   # close window
        "$mod, F,      fullscreen, 0"                                                 # true fullscreen
        "$mod, M,      fullscreen, 1"                                                 # pseudo/full (maximize-like)
        "$mod, R,      exec, fuzzel"                                                  # app launcher
        "$mod, E,      exec, thunar"                                                  # file manager
        "$mod, P,      exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/shot-$(date +%s).png"  # area screenshot
        "$mod, L,      exec, loginctl lock-session"                                   # lock session

        # --- Focus movement ----------------------------------------------------
        "$mod, LEFT,   movefocus, l"
        "$mod, RIGHT,  movefocus, r"
        "$mod, UP,     movefocus, u"
        "$mod, DOWN,   movefocus, d"

        # --- Move windows (Shift+arrows) --------------------------------------
        "$mod SHIFT, LEFT,  movewindow, l"
        "$mod SHIFT, RIGHT, movewindow, r"
        "$mod SHIFT, UP,    movewindow, u"
        "$mod SHIFT, DOWN,  movewindow, d"

        # --- Workspace scroll + direct jump -----------------------------------
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

        # --- Audio controls (PipeWire via wpctl; notifications w/ fallback) ---
        ", XF86AudioRaiseVolume, exec, ${hyprVol}/bin/hypr-vol up"
        ", XF86AudioLowerVolume, exec, ${hyprVol}/bin/hypr-vol down"
        ", XF86AudioMute,        exec, ${hyprVol}/bin/hypr-vol mute"
      ];

      ######################################
      ## Resize (Mod+Ctrl+Arrows)
      ##
      ## binde = “continuous” bindings; repeating adjusts in small steps.
      ######################################
      binde = [
        "$mod CTRL, LEFT,  resizeactive, -20 0"
        "$mod CTRL, RIGHT, resizeactive,  20 0"
        "$mod CTRL, UP,    resizeactive,  0 -20"
        "$mod CTRL, DOWN,  resizeactive,  0  20"
      ];

      ######################################
      ## Mouse bindings
      ##
      ## 272 = BTN_LEFT, 273 = BTN_RIGHT in Hyprland’s mouse descriptor format.
      ######################################
      bindm = [
        "$mod, mouse:272, movewindow"   # Mod + Left = drag to move
        "$mod, mouse:273, resizewindow" # Mod + Right = drag to resize
      ];

      ######################################
      ## Autostart services
      ##
      ## mako and Waybar are started here so they are present as soon as the
      ## compositor session begins. Clipboard watchers persist in the background.
      ######################################
      exec-once = [
        "mako"                          # notification daemon (themed via Stylix/mako)
        "Waybar"                        # status bar
        "wl-paste --type text  --watch cliphist store"   # text clipboard history
        "wl-paste --type image --watch cliphist store"   # image clipboard history
      ];
    };

    ######################################
    ## Optional raw Hyprland config
    ##
    ## Useful for temporary experiments or directives not surfaced in HM options.
    ######################################
    extraConfig = ''
      # Example:
      # windowrule = float,^(pavucontrol)$
    '';
  };

  ##############################################################################
  ## Helper tools and packages
  ##
  ## These are installed into the user profile so the hypr-vol script and
  ## bindings have guaranteed access to the referenced binaries.
  ##############################################################################
  programs.fuzzel.enable = true;  # lightweight Wayland app launcher

  home.packages = with pkgs; [
    # --- Core apps referenced by bindings -------------------------------------
    kitty            # terminal emulator used by $mod+Return
    xfce.thunar      # file manager used by $mod+E
    grim slurp       # screenshot + region selector used by $mod+P

    # --- Clipboard stack -------------------------------------------------------
    wl-clipboard     # wl-copy / wl-paste (Wayland-friendly)
    cliphist         # clipboard history store

    # --- Notifications & audio stack ------------------------------------------
    mako             # notification daemon (libnotify consumer)
    wireplumber      # provides `wpctl` for PipeWire control
    gawk             # used by hypr-vol for percentage math
    libnotify        # provides `notify-send` (preferred notification path)
    gnugrep          # used by hypr-vol to detect MUTED state
    coreutils        # sleep, etc., referenced in hypr-vol
  ];

  ##############################################################################
  ## Wayland environment variables
  ##
  ## These hints request native Wayland backends where possible. Electron apps
  ## generally honor NIXOS_OZONE_WL=1; Firefox reads MOZ_ENABLE_WAYLAND=1.
  ##############################################################################
  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";  # mark session as Wayland
    MOZ_ENABLE_WAYLAND = "1";      # prefer Wayland backend for Firefox
    QT_QPA_PLATFORM   = "wayland"; # prefer Wayland backend for Qt apps
    NIXOS_OZONE_WL    = "1";       # enable Wayland path for Chromium/Electron
  };
}

