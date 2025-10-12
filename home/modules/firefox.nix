# home/modules/firefox.nix
# =============================================================================
# Firefox (Home Manager) — flake-unified, declarative, Wayland/VAAPI ready
#
# - I bind the Firefox profile name to `defaultUser` from my flake.
# - I use the refactored bookmarks submodule (requires `force = true;`).
# - I use the current extensions schema (`extensions.packages`).
# - I tell Stylix which Firefox profile(s) to theme to silence its warning.
# =============================================================================
{ pkgs, defaultUser, colorScheme, ... }:
{
  programs.firefox = {
    enable = true;

    # I can switch to pkgs.firefox-bin if I prefer Mozilla’s binary build.
    package = pkgs.firefox;

    profiles."${defaultUser}" = {
      id = 0;
      name = defaultUser;   # <- this is the profile name Stylix needs
      isDefault = true;

      ########################################
      ## Preferences (about:config)
      ########################################
      settings = {
        # --- UI / Appearance ---
        "browser.startup.page" = 3;                 # restore previous session
        "browser.tabs.drawInTitlebar" = true;       # compact tabs (no OS titlebar)
        "browser.theme.dark-private-windows" = true;
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        # Follow my system theme for page content (0=system, 1=light, 2=dark)
        "layout.css.prefers-color-scheme.content-override" = 0;
        # Always show bookmarks toolbar
        "browser.toolbars.bookmarks.visibility" = "always";

        # --- Wayland + VAAPI / Performance ---
        "gfx.webrender.all" = true;                 # GPU compositor
        "widget.dmabuf.force-enabled" = true;       # Wayland DMA-BUF fast path
        "media.ffmpeg.vaapi.enabled" = true;        # VAAPI decode
        "media.hardware-video-decoding.enabled" = true;

        # --- Privacy / Usability ---
        "privacy.trackingprotection.enabled" = true;
        "network.cookie.cookieBehavior" = 1;        # block 3rd-party cookies
        "signon.rememberSignons" = false;           # don’t save passwords
        "privacy.resistFingerprinting" = false;     # keep normal DPI/UX scaling
        "privacy.clearOnShutdown.history" = false;  # keep history on exit

        # --- Misc ---
        "general.smoothScroll" = true;
        "browser.download.useDownloadDir" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "https://startpage.com/";
      };

      ########################################
      ## Bookmarks (refactored submodule)
      ########################################
      bookmarks = {
        force = true;  # overwrite manual changes on rebuild
        settings = [
          {
            name = "Toolbar";
            toolbar = true;  # render on visible Bookmarks Toolbar
            bookmarks = [
              { name = "NixOS";       url = "https://nixos.org";                 keyword = "nix"; }
              { name = "My GitHub";   url = "https://github.com/${defaultUser}"; }
              { name = "My NixOS";  url = "https://mynixos.com"; }
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
      ## Extensions (current HM schema)
      ########################################
      # Requires NUR overlay enabled in my flake:
      #   overlays = [ inputs.nur.overlays.default ];
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
  ## Stylix — tell it which Firefox profile(s) to theme
  ##########################################
  # This silences: “stylix: firefox: profileNames is not set…”
  stylix.targets.firefox.profileNames = [ defaultUser ];

  ##########################################
  ## Wayland environment for Firefox
  ##########################################
  # I force native Wayland backend (no XWayland).
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

  ##########################################
  ## Optional: VAAPI diagnostics (commented)
  ##########################################
  # home.packages = with pkgs; [
  #   libva-utils  # `vainfo` to verify VAAPI paths
  # ];
}

