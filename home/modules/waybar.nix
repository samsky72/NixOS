{ pkgs, ... }:
{
  ##########################################
  ## Waybar (Home Manager)
  ##########################################
  programs.waybar = {
    enable = true;

    # Run Waybar as a user systemd service (starts on graphical session)
    systemd.enable = true;

    # Main Waybar instance (single output by default; shows on all monitors)
    settings = [
      {
        layer = "top";
        position = "top";
        height = 30;
        margin = "6 6 0 6";     # top/right/bottom/left, leaves a nice gap

        # Choose what to show
        modules-left   = [ "hyprland/workspaces" "hyprland/language" "tray" ];
        modules-center = [ "clock" ];
        modules-right  = [ "cpu" "memory" "temperature" "pulseaudio" "network" "battery" "backlight" ];

        # --- Hyprland workspaces ---
        "hyprland/workspaces" = {
          # show all outputs so your dock is consistent
          all-outputs = true;
          format = "{icon}";
          # Optional icons (1..10)
          "format-icons" = {
            "1" = "󰎤"; "2" = "󰎧"; "3" = "󰎪"; "4" = "󰎭"; "5" = "󰎱";
            "6" = "󰎳"; "7" = "󰎶"; "8" = "󰎹"; "9" = "󰎼"; "10" = "󰽽";
            default = "";
            urgent  = "";
            active  = "";
          };
        };

        # --- Keyboard layout indicator (Hyprland) ---
        "hyprland/language" = {
          format = " {short}";
          # Example: show “US”, “RU”
        };

        # --- Clock ---
        clock = {
          format = "{:%a %d %b  %H:%M}";
          tooltip-format = "{:%Y-%m-%d %H:%M:%S}";
          interval = 1;
        };

        # --- Audio (PipeWire via PulseAudio compat) ---
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "";
          "format-icons" = { default = [ "" "" "" ]; headphones = ""; };
          # Click to open pavucontrol; scroll to adjust volume
          on-click = "pavucontrol";
          on-scroll-up = "pamixer -i 2";
          on-scroll-down = "pamixer -d 2";
        };

        # --- Network ---
        network = {
          format-wifi = "  {essid} {signalStrength}%";
          format-ethernet = "󰈀  {ifname}";
          format-disconnected = "󰤭";
          tooltip = true;
          interval = 5;
        };

        # --- Battery ---
        battery = {
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          "format-icons" = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰁹" ];
          states = { warning = 25; critical = 10; };
        };

        # --- Backlight (scroll to change) ---
        # If needed, set your device explicitly (e.g., "intel_backlight").
        backlight = {
          format = "󰃠 {percent}%";
          on-scroll-up   = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
          # device = "intel_backlight";
        };

        # --- CPU / RAM / Temp (nice quick glance) ---
        cpu = { format = " {usage}%"; tooltip = true; };
        memory = { format = " {used}GiB"; tooltip = true; };
        temperature = {
          format = " {temperatureC}°C";
          critical-threshold = 85;
        };

        tray = { spacing = 8; };
      }
    ];

    # Tokyonight-ish minimal style (Waybar CSS)
    style = ''
      * {
        font-family: JetBrainsMono Nerd Font, monospace;
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(26, 27, 38, 0.8); /* tokyonight bg */
        color: #c0caf5;                    /* tokyonight fg */
        border-radius: 12px;
        border: 1px solid rgba(80, 90, 120, 0.35);
      }

      #workspaces button {
        padding: 0 8px;
        color: #7aa2f7;
        background: transparent;
      }
      #workspaces button.active {
        color: #bb9af7;
        background: rgba(187, 154, 247, 0.12);
        border-radius: 10px;
      }
      #workspaces button.urgent {
        color: #f7768e;
        background: rgba(247, 118, 142, 0.15);
      }

      #tray, #clock, #cpu, #memory, #temperature, #pulseaudio,
      #network, #battery, #backlight, #language {
        padding: 0 10px;
      }

      #battery.warning { color: #e0af68; }
      #battery.critical { color: #f7768e; }

      tooltip {
        background: #1f2335;
        color: #c0caf5;
        border: 1px solid #414868;
        border-radius: 8px;
      }
    '';
  };

  # Handy tools used by Waybar actions
  home.packages = with pkgs; [
    brightnessctl   # for backlight scroll
    pamixer         # for volume scroll (pulseaudio/pipewire)
    pavucontrol     # audio panel on click
    iw              # extra wifi info (optional)
  ];
}

