# home/modules/firefox.nix
{ pkgs, ... }:
{
  ##########################################
  ## Firefox (Home Manager)
  ##########################################
  ##
  ## - Wayland + VAAPI tweaks for Hyprland
  ## - New HM schemas:
  ##     * Bookmarks:   profiles.<name>.bookmarks = { force; settings = [ ... ]; }
  ##     * Extensions:  profiles.<name>.extensions.packages = [ ... ]
  ## - Bookmarks Toolbar is forced visible (see settings block)
  ##########################################

  programs.firefox = {
    enable = true;

    # Choose the build (pkgs.firefox-bin is an option if you prefer Mozilla’s binaries)
    package = pkgs.firefox;

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      ########################################
      ## Preferences
      ########################################
      settings = {
        # --- UI / Appearance ---
        "browser.startup.page" = 3;                 # restore previous session
        "browser.tabs.drawInTitlebar" = true;       # hide system titlebar
        "browser.theme.dark-private-windows" = true;
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "layout.css.prefers-color-scheme.content-override" = 0; # follow system theme

        # Show the Bookmarks Toolbar:
        #   values: "always" | "newtab" | "never"
        "browser.toolbars.bookmarks.visibility" = "always";

        # --- Performance / Wayland VAAPI ---
        "gfx.webrender.all" = true;                 # GPU rendering
        "media.ffmpeg.vaapi.enabled" = true;        # hardware decode
        "widget.dmabuf.force-enabled" = true;       # Wayland/DMABUF path

        # --- Privacy / Usability ---
        "privacy.trackingprotection.enabled" = true;
        "network.cookie.cookieBehavior" = 1;        # block 3rd-party cookies
        "signon.rememberSignons" = false;           # don’t save passwords
        "privacy.resistFingerprinting" = false;     # keep normal scaling/UX
        "privacy.clearOnShutdown.history" = false;

        "general.smoothScroll" = true;
        "browser.download.useDownloadDir" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "https://startpage.com/";
      };

      ########################################
      ## Bookmarks (NEW HM schema)
      ########################################
      # Home Manager now requires the submodule with `force` and `settings`.
      bookmarks = {
        force = true;  # overwrite existing bookmarks on rebuild
        settings = [
          {
            name = "NixOS";
            url = "https://nixos.org";
            tags = [ "nixos" "docs" ];
            keyword = "nix";
          }
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
      };

      ########################################
      ## Extensions (NEW HM schema)
      ########################################
      # Requires NUR overlay available in Home Manager:
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

