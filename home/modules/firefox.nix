# home/modules/firefox.nix
# =============================================================================
# Firefox (Home Manager) — declarative profile with Wayland/VAAPI, extensions,
# bookmarks, and Stylix integration.
#
# Provides
#   • Profile bound to `defaultUser` from the flake (predictable profile name)
#   • Wayland + VAAPI-friendly prefs (WebRender + DMA-BUF path)
#   • Refactored bookmarks submodule (requires `force = true;`)
#   • Current extensions schema (`extensions.packages`) using NUR
#   • Stylix target so the theme applies without warnings
#
# Notes
#   • Profile name is the same as the system user (defaultUser). This silences
#     Stylix’ “profileNames is not set” warning when targeting Firefox.
#   • VAAPI on Wayland depends on system-side codecs (ffmpeg) and driver stack.
#     The prefs here only enable the client; actual decode support is provided
#     by the OS (see multimedia module).
#   • The `extensions.packages` attribute requires the NUR overlay (Rycee’s
#     firefox-addons). If NUR is not enabled, comment that section or switch
#     to `programs.firefox.profiles.<name>.extensions = [ ... ]` with manual XPI.
# =============================================================================
{ pkgs, defaultUser, ... }:
{
  programs.firefox = {
    enable = true;

    # Package selection:
    #   • pkgs.firefox      → distro build (default here)
    #   • pkgs.firefox-bin  → upstream binary; sometimes newer features arrive first
    package = pkgs.firefox;

    # Profile keyed to the flake’s defaultUser for predictable naming.
    profiles."${defaultUser}" = {
      id = 0;                 # stable ID; useful if multiple profiles are added later
      name = defaultUser;     # profile name used by Stylix theming
      isDefault = true;       # set as the default Firefox profile

      ########################################
      ## Preferences (about:config)
      ##
      ## These are minimal, pragmatic defaults that keep UX sane on Wayland,
      ## enable hardware decode where available, and avoid heavy-handed
      ## fingerprinting changes that break sites. Adjust per requirements.
      ########################################
      settings = {
        # --- UI / Appearance ---------------------------------------------------
        "browser.startup.page" = 3;                 # 0=blank, 1=home, 3=restore session
        "browser.tabs.drawInTitlebar" = true;       # use compact tab strip (no system titlebar)
        "browser.theme.dark-private-windows" = true;
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        # Follow system theme for page content: 0=system, 1=light, 2=dark
        "layout.css.prefers-color-scheme.content-override" = 0;
        # Always show Bookmarks Toolbar (use "never" or "newtab" if preferred)
        "browser.toolbars.bookmarks.visibility" = "always";

        # --- Wayland + VAAPI / Performance ------------------------------------
        "gfx.webrender.all" = true;                 # GPU compositor (WebRender)
        "widget.dmabuf.force-enabled" = true;       # DMA-BUF path for Wayland (faster video)
        "media.ffmpeg.vaapi.enabled" = true;        # prefer VAAPI when available
        "media.hardware-video-decoding.enabled" = true;  # general hardware decode toggle

        # --- Privacy / Usability ----------------------------------------------
        "privacy.trackingprotection.enabled" = true;   # balanced tracker blocking
        "network.cookie.cookieBehavior" = 1;           # block 3rd-party cookies (0=allow, 5=total)
        "signon.rememberSignons" = false;              # external password manager recommended
        "privacy.resistFingerprinting" = false;        # keep normal UI scaling (set true if needed)
        "privacy.clearOnShutdown.history" = false;     # retain history (set true if kiosk-like usage)

        # --- Misc --------------------------------------------------------------
        "general.smoothScroll" = true;                 # improved scroll feel
        "browser.download.useDownloadDir" = true;      # skip “where to save” prompts
        "browser.shell.checkDefaultBrowser" = false;   # avoid default browser nag
        "browser.startup.homepage" = "https://startpage.com/";  # simple starter; change as desired
      };

      ########################################
      ## Bookmarks (refactored submodule)
      ##
      ## The `force = true;` flag overwrites manual changes on rebuild, keeping
      ## the toolbar deterministic. Remove the flag to allow manual edits to
      ## persist across rebuilds.
      ########################################
      bookmarks = {
        force = true;  # keep declarative source of truth
        settings = [
          {
            name = "Toolbar";         # creates a folder bound to the toolbar
            toolbar = true;           # render the folder directly on the toolbar

            # Bookmarks within the toolbar
            bookmarks = [
              { name = "NixOS";     url = "https://nixos.org";                 keyword = "nix"; }
              { name = "My GitHub"; url = "https://github.com/samsky72"; }
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
      ##
      ## This relies on the NUR overlay (rycee) for packaged extensions. If NUR
      ## is not enabled in the flake, either:
      ##   • enable it: overlays = [ inputs.nur.overlays.default ];
      ##   • or comment this block and manage extensions manually.
      ########################################
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin   # efficient content blocker
        darkreader      # site-by-site dark mode
        bitwarden       # password manager
        vimium          # keyboard navigation
        sponsorblock    # skip sponsor segments on YT
      ];

      # Alternative (manual) extensions approach:
      # extensions = [
      #   { id = "uBlock0@raymondhill.net"; install_url = "...XPI url..."; }
      # ];
    };
  };

  ##########################################
  ## Stylix — target Firefox profile(s) for theming
  ##
  ## Prevents Stylix from warning about missing profile mappings by providing
  ## the exact profile name to theme. Multiple profiles can be listed.
  ##########################################
  stylix.targets.firefox.profileNames = [ defaultUser ];

  ##########################################
  ## Wayland environment for Firefox
  ##
  ## Enforces native Wayland backend (rather than XWayland). This is complementary
  ## to the Wayland/VAAPI prefs above and pairs with system PipeWire/FFmpeg setup.
  ##########################################
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

  ##########################################
  ## Optional: VAAPI diagnostics
  ##
  ## `vainfo` reports whether the VAAPI path and codecs are wired correctly. Enable
  ## this package if a quick diagnostic tool is useful at user scope.
  ##########################################
  # home.packages = with pkgs; [
  #   libva-utils  # provides `vainfo`
  # ];
}

