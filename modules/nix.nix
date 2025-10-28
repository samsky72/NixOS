# modules/nix.nix
# =============================================================================
# Modern Nix setup (flake-friendly) with safe, concise defaults.
#
# Provides
#   • Flakes + new CLI
#   • Store auto-optimisation (dedup) and weekly GC
#   • Sensible parallelism defaults
#   • Keeps derivations/outputs for easier debugging
#   • Nix CLI helpers (aliases + functions) for deps/refs/size/“what provides”
#
# Notes
#   • Host-agnostic; intended as a minimal, dependable base
#   • Extras are included as commented options for easy opt-in
# =============================================================================
{ lib, pkgs, ... }:
{
  ##########################################
  ## Nix (daemon) configuration
  ##########################################
  nix = {
    settings = {
      # --- Core features -------------------------------------------------------
      experimental-features = [ "nix-command" "flakes" ];
      accept-flake-config   = true;

      # --- Performance & scheduling -------------------------------------------
      auto-optimise-store = true;
      cores    = 16;           # 0 = use all CPU cores
      max-jobs = 4;      # parallel builds

      # --- Debug / reproducibility --------------------------------------------
      keep-outputs     = true;
      keep-derivations = true;

      # --- (Optional) Strictness / security -----------------------------------
      # sandbox = true;
      # require-sigs = true;

      # --- (Optional) Network/UX tweaks ---------------------------------------
      # log-lines = 50;
      # download-attempts = 3;
      # connect-timeout = 10;
      # http-connections = 50;

      # --- (Optional) Substituters --------------------------------------------
      # substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
      # trusted-public-keys = [
      #   "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      #   "nix-community.cachix.org-1:7pg7fT6NOYB3KZ0Zrx3qKZ8D+z4bQpLkzsb9ZL+3p88="
      # ];

      # --- (Optional) Trust model ---------------------------------------------
      # trusted-users = [ "root" "samsky" ];
    };

    # --- Garbage Collection ----------------------------------------------------
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 14d";
    };

    # --- (Optional) Periodic store optimisation -------------------------------
    # optimise.automatic = true;
  };

  ##########################################
  ## nixpkgs configuration (global)
  ##########################################
  nixpkgs = {
    config = {
      allowUnfree = true;
      # allowBroken = false;
    };

    # --- (Optional) Registry pinning ------------------------------------------
    # registry = { nixpkgs.flake = inputs.nixpkgs; };
  };

  ##########################################
  ## Nix CLI helpers (packages + aliases)
  ##########################################
  # Tools are installed here so they are available to users.
  environment.systemPackages = with pkgs; [
    nix-index            # nix-index + nix-locate (works with your nix-index-database)
    nix-tree             # dependency tree TUI
    nix-output-monitor   # `nom` for nicer build logs
    nvd                  # profile diff viewer (nix package diffs)
  ];

  # Short aliases for common dependency/reference queries.
  environment.shellAliases = {
    # Search nixpkgs (flake-style)
    nsp   = "nix search nixpkgs";

    # Forward dependency queries (what a path depends on)
    nreqs = "nix store query --requisites";   # transitive dependencies (closure)
    nrefs = "nix store query --references";   # direct references

    # Reverse dependency queries (what depends on a path)
    nrdeps = "nix store query --referrers";           # direct referrers
    nrdepsc = "nix store query --referrers-closure";  # transitive referrers

    # Closure size for a store path (human-readable)
    nsize = "nix path-info -Sh";

    # Explain why A depends on B
    nwhy = "nix why-depends";
  };

  # Shell functions (bash/zsh) for “what provides …” and path lookups.
  environment.interactiveShellInit = lib.mkAfter ''
    # Nix helpers (bash/zsh)

    # Evaluate the outPath of an attribute (e.g., nixpkgs#ripgrep)
    npath() {
      if [ $# -ne 1 ]; then
        echo "usage: npath ATTR_OR_FLAKE (e.g., nixpkgs#ripgrep)" >&2
        return 2
      fi
      nix eval --raw "$1".outPath
    }

    # Find which package provides a binary on PATH (requires nix-index database)
    # Example: nprovides rg   → shows pkgs that have bin/rg
    nprovides() {
      if [ $# -ne 1 ]; then
        echo "usage: nprovides CMD" >&2
        return 2
      fi
      nix-locate --minimal --top-level --whole-name "bin/$1"
    }

    # General file provider search inside store paths (exact or glob)
    # Example: nfile 'lib/libssl.so*'
    nfile() {
      if [ $# -lt 1 ]; then
        echo "usage: nfile GLOB" >&2
        return 2
      fi
      nix-locate --minimal --top-level "$@"
    }

    # Show GC roots referencing a store path (helps explain why it is kept)
    nroots() {
      if [ $# -ne 1 ]; then
        echo "usage: nroots /nix/store/…" >&2
        return 2
      fi
      nix-store --gc --print-roots | grep -- "$1" || true
    }
  '';

  ##########################################
  ## (Optional) Remote builders / cross
  ##########################################
  # nix.buildMachines = [ # … ];
  # nix.distributedBuilds = true;
  # nix.settings.builders-use-substitutes = true;

  ##########################################
  ## Notes / trade-offs
  ##########################################
  # • accept-flake-config: convenient for trusted repos; use --no-accept-flake-config for untrusted sources.
  # • keep-outputs / keep-derivations: improves cache hits and debugging; increases disk use.
  # • GC window: weekly with 14 days retained; adjust to taste.
}

