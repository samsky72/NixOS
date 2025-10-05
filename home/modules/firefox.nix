# home/modules/firefox.nix
{ pkgs, ... }:
{
  ##########################################
  ## Firefox Configuration (Home Manager)
  ##########################################
  ##
  ## - Wayland + VAAPI tweaks for Hyprland
  ## - New HM schemas:
  ##     * Bookmarks:   profiles.<name>.bookmarks = { force; settings = [ … ]; }
  ##     * Extensions:  profiles.<name>.extensions.packages = [ … ]
  ## - Bookmarks Toolbar items via a folder with `toolbar = true`
  ##########################################

  programs.firefox = {
    enable = true;
    package = pkgs.firefox; # or pkgs.firefox-bin

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      ########################################
      ## Preferences
      ########################################
      settings = {
        # --- UI / Appearance ---
        "browser.startup.page" = 3;               # restore previous session
        "browser.tabs.drawInTitlebar" = true;     # hide system titlebar
        "browser.theme.dark-private-windows" = true;
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "layout.css.prefers-color-scheme.content-override" = 0; # follow system theme

        # Show the Bookmarks Toolbar (always/newtab/never)
        "browser.toolbars.bookmarks.visibility" = "always";

        # --- Performance / Wayland VAAPI ---
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "widget.dmabuf.force-enabled" = true;

        # --- Privacy / Usability ---
        "privacy.trackingprotection.enabled" = true;
        "network.cookie.cookieBehavior" = 1;      # block 3rd-party cookies
        "signon.rememberSignons" = false;         # don’t save passwords
        "privacy.resistFingerprinting" = false;   # keep normal scaling/UX
        "privacy.clearOnShutdown.history" = false;

        "general.smoothScroll" = true;
        "browser.download.useDownloadDir" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "https://startpage.com/";
      };

      ########################################
      ## Bookmarks (toolbar-enabled)
      ########################################
      bookmarks = {
        force = true;  # overwrite manual changes on rebuild
        settings = [
          {
            # Everything inside appears on the Bookmarks Toolbar
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
      ## Extensions (requires NUR overlay in HM)
      ########################################
      # Ensure Home Manager has:
      #   nixpkgs.overlays = [ inputs.nur.overlays.default ];
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        darkreader
        bitwarden
        vimium
        sponsorblock
      ];
    };
  };

  ##########################################
  ## Wayland environment (per user)
  ##########################################
  home.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
}

