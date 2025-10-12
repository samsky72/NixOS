# modules/sysenv.nix
# =============================================================================
# System Environment (shared defaults across hosts)
#
# Goals:
# - Centralize system-wide environment knobs that every host benefits from.
# - Keep it KISS: clear structure, safe defaults, and easy host-level overrides.
# - Provide a practical CLI baseline, consistent shell behavior, and well-documented
#   aliases (including opinionated NixOS helpers with backup & cleanup flows).
#
# Inputs (via specialArgs in your flake):
# - `locale`: { timeZone, defaultLocale, supportedLocales, xkb = { layout, options, ... } }
#
# Overriding:
# - Many options here use `lib.mkDefault` so a host-specific module can override
#   without forcing `mkForce`. Treat this module as a sane “floor”, not a “ceiling”.
# =============================================================================
{ lib, pkgs, locale, ... }:
let
  inherit (lib) mkDefault;
in
{
  ##########################################
  ## Time, Locale, and Keyboard (from flake)
  ##########################################

  # Timezone is taken from the flake and can be overridden per host if you travel
  # or for servers in other regions.
  time.timeZone = mkDefault locale.timeZone;

  # Locales: default LANG plus the set glibc should generate. Keep this lean:
  # only generate the locales I’ll use to avoid long glibc activations.
  i18n.defaultLocale    = mkDefault locale.defaultLocale;
  i18n.supportedLocales = mkDefault locale.supportedLocales;

  # Make virtual terminals (Linux console) respect XKB. This helps non-US layouts
  # on TTYs (Ctrl+Alt+F1..F6) match my desktop/X/Wayland keyboard settings.
  console.useXkbConfig = true;

  # XKB defaults for X11 and many Wayland compositors.
  # If I define xkb.model/variant in the flake, I can also pass them through.
  services.xserver.xkb = {
    inherit (locale.xkb) layout options;
    # inherit (locale.xkb) model variant;
  };

  # Export XKB defaults for Wayland-aware / XDG-aware apps that honor env vars.
  # This is helpful for tools that don’t read the NixOS xkb options directly.
  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT  = locale.xkb.layout;
    XKB_DEFAULT_OPTIONS = locale.xkb.options;
    # XKB_DEFAULT_MODEL   = locale.xkb.model or "";
    # XKB_DEFAULT_VARIANT = locale.xkb.variant or "";
  };

  ##########################################
  ## System-wide CLI toolset
  ##########################################
  # A curated baseline: modern ls/grep/find replacements, diagnostics, archivers,
  # and common dev ergonomics. Trim or extend per taste.
  environment.systemPackages = with pkgs; [
    ## shells & basics
    bashInteractive
    zsh
    coreutils
    findutils
    gnugrep
    gawk
    gnused

    ## file managers / TUI
    mc

    ## archive / compression (rich CLI coverage)
    zip unzip
    xz
    p7zip
    zstd
    gzip bzip2 lz4 lzip lrzip
    libarchive
    cabextract
    unar
    unrar

    ## networking & diagnostics
    curl wget
    git
    iproute2 iputils
    traceroute
    dnsutils
    nmap

    ## filesystem / process / monitoring
    eza
    tree
    ripgrep
    fd
    du-dust
    duf
    procs
    htop
    lsof
    ncdu
    rsync

    ## data wrangling
    jq
    yq-go

    ## misc
    file
    which
    tokei
 
    udiskie
    udevil

    usbutils
    psmisc
  ];

  # Make zsh and bash available for login/shell switching (e.g., `chsh -s`).
  environment.shells = with pkgs; [ zsh bashInteractive ];

  # Enable system-level Zsh integration (completions, etc.). User-level specifics
  # are in my Home Manager zsh module; this leaves the base ready system-wide.
  programs.zsh.enable = true;

  ##########################################
  ## Sensible environment variables
  ##########################################
  # System defaults I expect on a developer machine and that work well for
  # both console and GUI sessions. Use `mkDefault` so hosts can override easily.
  environment.variables = {
    EDITOR = mkDefault "nvim";
    VISUAL = mkDefault "nvim";
    PAGER  = mkDefault "less";
    LESS   = mkDefault "-R --use-color -M --long-prompt --ignore-case";
    LESSHISTFILE = mkDefault "-";
    NIXOS_OZONE_WL = mkDefault "1";
    LANG = mkDefault locale.defaultLocale;
  };

  ##########################################
  ## Global shell aliases (Bash & Zsh)
  ##########################################
  environment.shellAliases = {
    # ---------- Files & listings ----------
    ls  = "eza --group-directories-first";
    ll  = "eza -alh --group-directories-first --git";
    la  = "eza -a";
    l   = "eza -1";
    lt  = "eza -T";
    lS  = "eza -l --sort=size";

    # ---------- Search helpers ----------
    rg  = ''rg -n --hidden --glob "!.git"'';
    fd  = "fd --hidden --exclude .git";

    # ---------- QoL replacements ----------
    grep = "grep --color=auto";
    diff = "diff --color=auto";
    ip   = "ip -c";
    df   = "duf";
    du   = "dust";
    top  = "htop";

    # ---------- Git short-hands ----------
    gs = "git status -sb";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git log --oneline --graph --decorate";

    # ---------- Safety nets ----------
    rm = "rm -i";
    cp = "cp -i";
    mv = "mv -i";

    # ---------- NixOS helpers (KISS) ----------
    system-rebuild = "sudo nixos-rebuild switch --flake .#$(hostname -s)";

    system-update = ''
      sh -c 'ts=$(date +"%Y%m%d-%H%M%S"); bak="flake.lock.bak-$ts"; \
        [ -f flake.lock ] && cp -f flake.lock "$bak" || true; \
        if nix flake update && sudo nixos-rebuild switch --flake .#"$(hostname -s)"; then \
          echo "✔ Flake updated and system switched. Backup kept at: $bak"; \
        else \
          echo "✖ Update or rebuild failed. Restoring flake.lock from: $bak"; \
          [ -f "$bak" ] && mv -f "$bak" flake.lock; \
          exit 1; \
        fi'
    '';

    # WARNING: This deletes ALL generations (root + user). Run when stable.
    system-cleanup = "sudo nix-collect-garbage -d; nix-collect-garbage -d; nix store optimise -v";
  };

  ##########################################
  ## Unified init for ALL interactive shells
  ##########################################
  # This runs for bash, zsh, etc. on interactive startup.
  # By default, auto-cd to ~/NixOS if it exists (so I land in my repo).
  # Set NO_AUTO_CD_NIXOS=1 to disable.
  environment.interactiveShellInit = lib.mkAfter ''
    if [ -z "''${NO_AUTO_CD_NIXOS-}" ] && [ -d "$HOME/NixOS" ]; then
      cd "$HOME/NixOS"
    fi
  '';

  ##########################################
  ## PATH & profile tweaks
  ##########################################
  environment.pathsToLink = [ "/share/zsh" ];

  environment.etc."profile.d/10-local-path.sh".text = ''
    if [ -d /usr/local/bin ]; then
      export PATH="/usr/local/bin:$PATH"
    fi
  '';

  ##########################################
  ## Removable media auto-mount (Wayland/Thunar friendly)
  ##########################################
  # I enable udisks2 (device management daemon) and gvfs (volume monitors)
  # so file managers (e.g., Thunar) can see and mount devices.
  # I also run udiskie in the user session for hands-off automounts + notifications.
  services.udisks2.enable = true;   # system daemon for disks/partitions
  services.gvfs.enable = true;      # desktop volume monitoring (needed by Thunar/GTK apps)

  ##########################################
  ## Documentation & editors
  ##########################################
  documentation.man.enable = true;

  programs.nano.enable = false;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}

