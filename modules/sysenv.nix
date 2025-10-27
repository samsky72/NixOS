# modules/sysenv.nix
# =============================================================================
# System environment (shared defaults across hosts)
#
# Scope
#   • Centralizes system-wide environment defaults
#   • Provides a practical CLI baseline and consistent shell behavior
#   • Supplies documented aliases, including NixOS helpers with backup/cleanup
#
# Inputs (via flake specialArgs)
#   • locale: { timeZone, defaultLocale, supportedLocales, xkb = { layout, options, ... } }
#
# Notes
#   • Uses lib.mkDefault for easy host overrides without mkForce.
#   • Intended as a “floor” of sane defaults rather than a “ceiling”.
# =============================================================================
{ lib, pkgs, locale, ... }:
let
  inherit (lib) mkDefault mkAfter;  # mkDefault → lower-priority defaults; mkAfter → append shell init
in
{
  ##########################################
  ## Time, locale, and keyboard (from flake)
  ##########################################

  # Time zone (can be overridden per host if required).
  time.timeZone = mkDefault locale.timeZone;

  # Default locale and the set of locales glibc should generate.
  # Keeping this list lean speeds up activations.
  i18n.defaultLocale    = mkDefault locale.defaultLocale;
  i18n.supportedLocales = mkDefault locale.supportedLocales;

  # Make virtual terminals (Linux console) follow XKB settings.
  console.useXkbConfig = true;

  # XKB defaults for X11 and Wayland-aware compositors (model/variant optional).
  services.xserver.xkb = {
    inherit (locale.xkb) layout options; # e.g., "us,ru" and "grp:win_space_toggle"
    # inherit (locale.xkb) model variant; # uncomment if provided in flake
  };

  # Export XKB defaults via environment for tools that read XKB_* vars.
  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT  = locale.xkb.layout;   # default keyboard layout(s)
    XKB_DEFAULT_OPTIONS = locale.xkb.options;  # default XKB options
    # XKB_DEFAULT_MODEL   = locale.xkb.model or "";
    # XKB_DEFAULT_VARIANT = locale.xkb.variant or "";
  };

  ##########################################
  ## System-wide CLI toolset
  ##########################################
  # Curated baseline: shells, archives, diagnostics, monitors, and helpers.
  # Each entry includes a short purpose note for quick recall.
  environment.systemPackages = with pkgs; [
    # --- Shells & basics ---
    bashInteractive        # interactive bash for login/shell switching
    zsh                    # alternative interactive shell
    coreutils              # GNU core utilities
    findutils              # find/xargs
    gnugrep                # grep with PCRE/color
    gawk                   # awk implementation
    gnused                 # sed implementation

    gcc                    # system C toolchain (headers/compilers)

    # --- TUI file manager ---
    mc                     # Midnight Commander

    # --- Archive / compression ---
    zip unzip              # zip archives
    xz                     # xz compression
    p7zip                  # 7z/7zip formats
    zstd                   # zstd compression
    gzip bzip2             # gzip/bzip2 formats
    lz4 lzip lrzip         # extra compressors
    libarchive             # bsdtar and archive libs
    cabextract             # Microsoft CAB files
    unar                   # universal archive extractor
    unrar                  # RAR extractor (non-free)

    # --- Networking & diagnostics ---
    curl wget              # HTTP(S) clients
    git                    # VCS client
    iproute2 iputils       # ip/ss + ping/tracepath
    traceroute             # classic traceroute
    dnsutils               # dig/nslookup
    nmap                   # scanner + ncat

    # --- Filesystem / process / monitoring ---
    eza                    # modern ls
    tree                   # directory tree
    ripgrep                # fast grep
    fd                     # modern find
    du-dust                # disk usage (du replacement)
    duf                    # disk free (df replacement)
    procs                  # modern ps
    htop                   # process viewer
    lsof                   # open files listing
    ncdu                   # interactive disk usage
    rsync                  # file synchronization

    # --- Data wrangling ---
    jq                     # JSON processor
    yq-go                  # YAML processor (Go-based)

    # --- Misc ---
    file                   # file type detection
    which                  # command resolver
    tokei                  # code statistics

    # --- Removable media helpers ---
    udiskie                # user-space automounter
    udevil                 # lightweight mount helpers

    # --- USB / misc tools ---
    usbutils               # lsusb
    psmisc                 # pstree/killall/fuser

    # --- Hardware inspection ---
    pciutils            # lspci
    dmidecode           # SMBIOS/firmware info

    # --- Documentation / QoL additions ---
    man-pages           # GNU man pages
    man-pages-posix     # POSIX man pages
    lesspipe            # smarter preprocessing for `less`
  ];

  # Make zsh and bash available as valid login shells (usable via `chsh -s`).
  environment.shells = with pkgs; [ zsh bashInteractive ];

  # Enable system-level Zsh integration (completions, etc.); user-specific setup
  # is typically handled in Home Manager.
  programs.zsh.enable = true;

  ##########################################
  ## Sensible environment variables
  ##########################################
  # Defaults suitable for both TTY and GUI sessions. mkDefault allows overrides.
  environment.variables = {
    EDITOR         = mkDefault "nvim";                     # default editor
    VISUAL         = mkDefault "nvim";                     # default GUI editor
    PAGER          = mkDefault "less";                     # pager
    LESS           = mkDefault "-R --use-color -M --long-prompt --ignore-case"; # sane less flags
    LESSHISTFILE   = mkDefault "-";                        # disable less history file
    NIXOS_OZONE_WL = mkDefault "1";                        # Wayland for Chromium/Electron
    LANG           = mkDefault locale.defaultLocale;       # ensure LANG matches defaultLocale
  };

  ##########################################
  ## Unified aliases (Bash & Zsh)
  ##########################################
  environment.shellAliases = {
    # Files & listings
    ls  = "eza --group-directories-first";                # compact listing
    ll  = "eza -alh --group-directories-first --git";     # long + hidden + git
    la  = "eza -a";                                       # all, including dotfiles
    l   = "eza -1";                                       # one entry per line
    lt  = "eza -T";                                       # tree view
    lS  = "eza -l --sort=size";                           # sort by size

    # Search helpers
    rg  = ''rg -n --hidden --glob "!.git"'';              # recursive search ignoring .git
    fd  = "fd --hidden --exclude .git";                   # fast file finder

    # QoL replacements
    grep = "grep --color=auto";                           # colored grep
    diff = "diff --color=auto";                           # colored diff
    ip   = "ip -c";                                       # colored ip output
    df   = "duf";                                         # df replacement
    du   = "dust";                                        # du replacement
    top  = "htop";                                        # top replacement

    # Git short-hands
    gs = "git status -sb";                                # concise status
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git log --oneline --graph --decorate";

    # Safety nets
    rm = "rm -i";                                         # confirm deletions
    cp = "cp -i";                                         # confirm overwrites
    mv = "mv -i";                                         # confirm overwrites

    # NixOS helpers
    system-rebuild = "sudo nixos-rebuild switch --flake .#$(hostname -s)";  # rebuild current host

    # Update flake with backup; restore lock on failure; then rebuild.
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

    # WARNING: deletes ALL generations (root + user). Use only when safe.
    system-cleanup = "sudo nix-collect-garbage -d; nix-collect-garbage -d; nix store optimise -v";
  };

  ##########################################
  ## Unified init for interactive shells
  ##########################################
  # Executes for bash, zsh, etc. on interactive startup.
  # Automatically cd into ~/NixOS if present; disable via NO_AUTO_CD_NIXOS=1.
  environment.interactiveShellInit = mkAfter ''
    if [ -z "''${NO_AUTO_CD_NIXOS-}" ] && [ -d "$HOME/NixOS" ]; then
      cd "$HOME/NixOS"
    fi
  '';

  ##########################################
  ## PATH & profile tweaks
  ##########################################
  environment.pathsToLink = [ "/share/zsh" ];  # expose system zsh completions

  # Lightweight PATH prepend for /usr/local/bin if it exists.
  environment.etc."profile.d/10-local-path.sh".text = ''
    if [ -d /usr/local/bin ]; then
      export PATH="/usr/local/bin:$PATH"
    fi
  '';

  ##########################################
  ## Removable media support (Wayland/Thunar friendly)
  ##########################################
  services.udisks2.enable = true;  # disk/partition management daemon
  services.gvfs.enable    = true;  # desktop volume monitoring/backends

  ##########################################
  ## Documentation & editors
  ##########################################
  documentation.man.enable = true; # manual pages

  programs.nano.enable = false;    # keep nano out if neovim is preferred
  programs.neovim = {
    enable        = true;          # provide nvim
    defaultEditor = true;          # symlink EDITOR to nvim by default
  };
}

