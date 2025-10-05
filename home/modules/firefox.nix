# home/modules/firefox.nix
{ pkgs, ... }:
{
  ##########################################
  ## Firefox Configuration (Home Manager)
  ##########################################
  ##
  ## This module provides a fully declarative Firefox setup with:
  ##  - GPU acceleration (Wayland + VAAPI tweaks)
  ##  - Privacy-friendly and ergonomic defaults
  ##  - Declarative bookmarks and extensions (per-profile)
  ##  - Persistent settings on rebuild via Home Manager
  ##
  ## Works well under Wayland/Hyprland environments.
  ##########################################

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;  # You can switch to `pkgs.firefox-bin` for faster startup

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      ########################################
      ## Preferences
      ########################################
      ## These map directly to Firefox's about:config options.
      ## Customize UI, behavior, privacy, and performance here.
      ########################################
      settings = {
        # --- UI / Appearance ---
        "browser.startup.page" = 3;               # Restore previous session on startup
        "browser.tabs.drawInTitlebar" = true;     # Hide OS titlebar for compact tabs
        "browser.theme.dark-private-windows" = true;
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "layout.css.prefers-color-scheme.content-override" = 0; # Follow system theme (light/dark)

        # Show the Bookmarks Toolbar ("always", "newtab", or "never")
        "browser.toolbars.bookmarks.visibility" = "always";

        # --- Performance / Wayland VAAPI ---
        "gfx.webrender.all" = true;               # Enable GPU rendering
        "media.ffmpeg.vaapi.enabled" = true;      # Hardware video decoding
        "widget.dmabuf.force-enabled" = true;     # Force DMA-BUF for Wayland acceleration

        # --- Privacy / Usability ---
        "privacy.trackingprotection.enabled" = true;   # Enable tracking protection
        "network.cookie.cookieBehavior" = 1;           # Block 3rd-party cookies
        "signon.rememberSignons" = false;              # Don’t save passwords
        "privacy.resistFingerprinting" = false;        # Allow normal DPI scaling
        "privacy.clearOnShutdown.history" = false;     # Keep history on exit

        # --- Miscellaneous Tweaks ---
        "general.smoothScroll" = true;                 # Smooth scrolling
        "browser.download.useDownloadDir" = true;      # Save files to default folder
        "browser.shell.checkDefaultBrowser" = false;   # Disable “default browser” prompt
        "browser.startup.homepage" = "https://startpage.com/"; # Custom homepage
      };

      ########################################
      ## Bookmarks (Toolbar Enabled)
      ########################################
      ## Declarative bookmarks follow the new Home Manager schema:
      ##   programs.firefox.profiles.<name>.bookmarks = { force; settings = [ … ]; }
      ## A folder with `toolbar = true` places its entries on the
      ## visible Bookmarks Toolbar.
      ########################################
      bookmarks = {
        force = true;  # Overwrite manual changes on rebuild
        settings = [
          {
            # Everything inside this folder appears in the Bookmarks Toolbar
            name = "Toolbar";
            toolbar = true;

            bookmarks = [
              { name = "NixOS";  url = "https://nixos.org"; keyword = "nix"; }
              { name = "My GitHub"; url = "https://github.com/samsky72"; }
              "separator"
              {
                name = "Docs";
                bookmarks = [
                  { name = "Hyprland Wiki"; url = "https://wiki.hyprland.org/"; }
                  { name = "Home Manager";  url = "https://nix-community.github.io/home-manager/"; }
                ];
              }
            ];
          }
        ];
      };

      ########################################
      ## Extensions
      ########################################
      ## Declarative extension configuration uses the `.packages` attribute.
      ## Requires NUR overlay: `nixpkgs.overlays = [ inputs.nur.overlays.default ];`
      ########################################
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin      # Ad blocker
        darkreader         # Dark mode on all sites
        bitwarden          # Password manager
        vimium             # Vim-style key navigation
        sponsorblock       # Skip YouTube sponsor segments
      ];
    };
  };

  ##########################################
  ## Wayland Environment Variables
  ##########################################
  ## Ensures Firefox uses native Wayland backend
  ## instead of the XWayland fallback.
  ##########################################
  home.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
}

