# home/modules/waybar.nix
# =============================================================================
# Waybar (Home Manager) — same size, bigger workspace icons, NEW icon set
#
# I keep the bar height the same and only change the workspace icons.
# Current set: **NF roles** (terminal/web/files/steam).
# Decoration for the **selected** workspace is removed (no bubble background).
# =============================================================================
{ pkgs, lib, colorScheme, ... }:
let
  withHash = v: if lib.hasPrefix "#" v then v else "#${v}";
  p = lib.mapAttrs (_: withHash) colorScheme.palette;

  bg      = p.base00;
  bg2     = p.base01;
  dim     = p.base03;
  fg      = p.base05;
  red     = p.base08;
  yellow  = p.base0A;
  blue    = p.base0D;
  purple  = p.base0E;

  ws_active_fg = purple;
  ws_idle_fg   = blue;
  ws_urgent_fg = red;

  # Enlarge workspace icons only (bar height unchanged)
  ws_icon_px = 20;

  # --- Icon presets -----------------------------------------------------------
  icons_black_circled = { "1" = "➊"; "2" = "➋"; "3" = "➌"; "4" = "➍"; default = "●"; };
  icons_white_circled = { "1" = "①"; "2" = "②"; "3" = "③"; "4" = "④"; default = "○"; };
  icons_plain_digits  = { "1" = "1";  "2" = "2";  "3" = "3";  "4" = "4";  default = "•"; };
  icons_nf_roles      = { "1" = ""; "2" = ""; "3" = ""; "4" = ""; default = ""; };

  # Active icon set:
  ws_icons = icons_nf_roles;
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [
      {
        layer = "top";
        position = "top";

        # Bar size unchanged
        height = 42;
        margin = "10 10 0 10";

        modules-left   = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right  = [
          "cpu" "memory" "temperature" "pulseaudio" "network" "battery" "backlight"
          "clock" "hyprland/language" "tray"
        ];

        # Workspaces: same strip on both screens, icons applied
        "hyprland/workspaces" = {
          all-outputs = true;
          format = "{icon}";
          on-click = "hyprctl dispatch workspace {id}";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";

          # If I want them visible even when empty:
          # "persistent-workspaces" = { "*" = [ 1 2 3 4 ]; };

          # Remove active icon override to avoid “decoration” changes
          "format-icons" = ws_icons // {
            urgent = "";
            # active = "";  # ← removed to keep the same icon when selected
          };
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 100;
          separate-outputs = false;
        };

        "hyprland/language" = { format = " {short}"; };

        clock = {
          format = "{:%a %d %b  %H:%M}";
          tooltip-format = "{:%Y-%m-%d %H:%M:%S}";
          interval = 1;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "";
          "format-icons" = { default = [ "" "" "" ]; headphones = ""; };
          on-click = "pavucontrol";
          on-scroll-up = "pamixer -i 2";
          on-scroll-down = "pamixer -d 2";
        };

        network = {
          format-wifi = "  {essid} {signalStrength}%";
          format-ethernet = "󰈀  {ifname}";
          format-disconnected = "󰤭";
          tooltip = true;
          interval = 5;
        };

        battery = {
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          "format-icons" = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰁹" ];
          states = { warning = 25; critical = 10; };
        };

        backlight = {
          format = "󰃠 {percent}%";
          on-scroll-up   = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };

        cpu         = { format = " {usage}%";         tooltip = true; };
        memory      = { format = "󰍛 {used}GiB";        tooltip = true; };
        temperature = { format = " {temperatureC}°C"; critical-threshold = 85; };

        tray = { spacing = 10; };
      }
    ];

    style = ''
      * {
        font-family: JetBrainsMono Nerd Font, monospace;
        font-size: 14px;   /* bar text size unchanged */
        min-height: 0;
      }

      window#waybar {
        background: ${bg};
        color: ${fg};
        border-radius: 14px;
        border: 1px solid ${dim};
      }

      /* Larger workspace icons ONLY — bar height remains 42px */
      #workspaces button {
        padding: 0 12px;               /* keep vertical size tight */
        color: ${ws_idle_fg};
        background: transparent;
        font-size: ${toString ws_icon_px}px;
      }

      /* Selected workspace — no bubble/decoration */
      #workspaces button.active {
        color: ${ws_active_fg};        /* keep a subtle color accent */
        background: transparent;       /* remove background */
        border-radius: 0;              /* remove rounded bubble */
        font-weight: 500;              /* or 400 if you want zero emphasis */
        box-shadow: none;              /* ensure no shadow glow */
      }

      #workspaces button.urgent {
        color: ${ws_urgent_fg};
        background: ${bg2};
        border-radius: 10px;
      }

      #tray, #clock, #cpu, #memory, #temperature, #pulseaudio,
      #network, #battery, #backlight, #language, #window {
        padding: 0 14px;
      }

      #battery.warning  { color: ${yellow}; }
      #battery.critical { color: ${red}; }

      tooltip {
        background: ${bg2};
        color: ${fg};
        border: 1px solid ${dim};
        border-radius: 10px;
      }
    '';
  };

  home.packages = with pkgs; [
    brightnessctl pamixer pavucontrol iw lm_sensors
  ];
}

