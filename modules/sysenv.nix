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
  # only generate the locales you’ll use to avoid long glibc activations.
  i18n.defaultLocale    = mkDefault locale.defaultLocale;
  i18n.supportedLocales = mkDefault locale.supportedLocales;

  # Make virtual terminals (Linux console) respect XKB. This helps non-US layouts
  # on TTYs (Ctrl+Alt+F1..F6) match your desktop/X/Wayland keyboard settings.
  console.useXkbConfig = true;

  # XKB defaults for X11 and many Wayland compositors.
  # If you define xkb.model/variant in the flake, you can also pass them through.
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
  # and common dev ergonomics. Trim or extend per your taste.
  environment.systemPackages = with pkgs; [
    ## shells & basics
    bashInteractive        # interactive bash with readline
    zsh                    # alternative interactive shell
    coreutils              # GNU core (ls/cp/mv/cat, etc.)
    findutils              # find/xargs
    gnugrep                # GNU grep (grep/egrep/fgrep)
    gawk                   # GNU awk
    gnused                 # GNU sed

    ## file managers / TUI
    mc                     # Midnight Commander (two-pane file manager)

    ## archive / compression (rich CLI coverage)
    zip unzip              # zip format (create/extract)
    xz                     # .xz
    p7zip                  # 7z/7za multi-format archiver
    zstd                   # zstandard compressor
    gzip bzip2 lz4 lzip lrzip
    libarchive             # bsdtar/bsdcpio; understands many formats
    cabextract             # Microsoft .cab
    unar                   # The Unarchiver CLI (wide support)
    unrar                  # .rar extractor (unfree — allowed by allowUnfree in flake)

    ## networking & diagnostics
    curl wget              # HTTP(S) clients
    git                    # version control
    iproute2 iputils       # ip, ss, ping, arping
    traceroute             # route diagnostics
    dnsutils               # dig, nslookup
    nmap                   # quick network probing / port scan

    ## filesystem / process / monitoring
    eza                    # modern ls replacement
    tree                   # directory tree
    ripgrep                # fast grep
    fd                     # fast find
    du-dust                # nicer du
    duf                    # nicer df
    procs                  # nicer ps
    htop                   # interactive process monitor
    lsof                   # list open files
    ncdu                   # interactive disk usage browser
    rsync                  # robust sync/copy

    ## data wrangling
    jq                     # JSON CLI
    yq-go                  # YAML CLI

    ## misc
    file                   # file type detection
    which                  # locate executables in PATH
    tokei                  # code statistics by language
  ];

  # Make zsh and bash available for login/shell switching (e.g., `chsh -s`).
  environment.shells = with pkgs; [ zsh bashInteractive ];

  # Enable system-level Zsh integration (completions, etc.). User-level specifics
  # are in your Home Manager zsh module; this leaves the base ready system-wide.
  programs.zsh.enable = true;

  ##########################################
  ## Sensible environment variables
  ##########################################
  # System defaults you’d expect on a developer machine and that work well for
  # both console and GUI sessions. Use `mkDefault` so hosts can override easily.
  environment.variables = {
    EDITOR = mkDefault "nvim";        # default CLI editor (programs.neovim below)
    VISUAL = mkDefault "nvim";        # preferred GUI editor (also nvim)
    PAGER  = mkDefault "less";        # sane pager defaults
    LESS   = mkDefault "-R --use-color -M --long-prompt --ignore-case";
    LESSHISTFILE = mkDefault "-";     # do not persist `less` history
    NIXOS_OZONE_WL = mkDefault "1";   # prefer Wayland for Electron/Chromium apps
    LANG = mkDefault locale.defaultLocale;  # ensure $LANG in non-login shells too
  };

  ##########################################
  ## Global shell aliases (Bash & Zsh)
  ##########################################
  # Centralized aliases so both bash and zsh pick them up identically.
  environment.shellAliases = {
    # ---------- Files & listings ----------
    ls  = "eza --group-directories-first";                 # modern ls; directories first
    ll  = "eza -alh --group-directories-first --git";      # long list incl. hidden + git
    la  = "eza -a";                                        # show all (incl. dotfiles)
    l   = "eza -1";                                        # one entry per line
    lt  = "eza -T";                                        # tree view
    lS  = "eza -l --sort=size";                            # sort by size

    # ---------- Search helpers ----------
    rg  = ''rg -n --hidden --glob "!.git"'';               # ripgrep incl. dotfiles, skip .git/
    fd  = "fd --hidden --exclude .git";                    # fd incl. dotfiles, skip .git/

    # ---------- QoL replacements ----------
    grep = "grep --color=auto";                            # colorized grep output
    diff = "diff --color=auto";                            # colorized diff
    ip   = "ip -c";                                        # colored iproute2 output
    df   = "duf";                                          # friendlier `df`
    du   = "dust";                                         # friendlier `du`
    top  = "htop";                                         # friendlier `top`

    # ---------- Git short-hands ----------
    gs = "git status -sb";                                 # concise status
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git log --oneline --graph --decorate";

    # ---------- Safety nets (confirm destructive ops) ----------
    rm = "rm -i";                                          # prompt before remove
    cp = "cp -i";                                          # prompt before overwrite
    mv = "mv -i";                                          # prompt before overwrite

    # ---------- NixOS helpers (KISS) ----------
    # Rebuild current host and switch immediately.
    # - Uses `hostname -s` to select the flake’s machine entry (.#<host>).
    system-rebuild = "sudo nixos-rebuild switch --flake .#$(hostname -s)";

    # Update flake inputs with a TIMESTAMPED backup of flake.lock, then rebuild & switch.
    # - Backup filename: flake.lock.bak-YYYYMMDD-HHMMSS (kept on success for manual rollback).
    # - On failure: original flake.lock is restored from the backup; exit non-zero.
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

    # Fully collect garbage (DELETE ALL generations for both root and user) and optimize store.
    # - This removes rollbacks; run only when you’re confident the system is stable.
    system-cleanup = "sudo nix-collect-garbage -d; nix-collect-garbage -d; nix store optimise -v";
  };

  ##########################################
  ## Unified init for ALL interactive shells
  ##########################################
  # This runs for bash, zsh, etc. on interactive startup.
  # By default, auto-cd to ~/NixOS if it exists (so you land in your repo).
  # Set NO_AUTO_CD_NIXOS=1 in your environment to disable this behavior.
  environment.interactiveShellInit = lib.mkAfter ''
    if [ -z "''${NO_AUTO_CD_NIXOS-}" ] && [ -d "$HOME/NixOS" ]; then
      cd "$HOME/NixOS"
    fi
  '';

  ##########################################
  ## PATH & profile tweaks
  ##########################################
  # Link extra trees from /nix/store into /run/current-system/sw so shells can
  # discover completions/plugins without per-package glue.
  environment.pathsToLink = [ "/share/zsh" ];

  # Keep /usr/local/bin early in $PATH for third-party installers that drop binaries there.
  # This is intentionally conservative: we do not override Nix’s /run/current-system/sw/bin precedence,
  # just ensure /usr/local/bin is present and early enough.
  environment.etc."profile.d/10-local-path.sh".text = ''
    if [ -d /usr/local/bin ]; then
      export PATH="/usr/local/bin:$PATH"
    fi
  '';

  ##########################################
  ## Documentation & editors
  ##########################################
  documentation.man.enable = true;     # manpages are life

  programs.nano.enable = false;        # remove nano (NixOS enables it by default)
  programs.neovim = {
    enable = true;                     # install neovim system-wide
    defaultEditor = true;              # sets $EDITOR/$VISUAL to nvim globally
  };
}

