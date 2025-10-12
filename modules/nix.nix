# modules/nix.nix
# =============================================================================
# Modern Nix setup (flake-friendly) with safe, concise defaults.
#
# What I get:
# - Flakes + new CLI enabled
# - Store auto-optimisation (dedup) and weekly GC
# - Reasonable parallelism defaults
# - Keep derivations/outputs for easier debugging
#
# KISS: minimal core that works well everywhere, with opt-in extras commented.
# =============================================================================
{ ... }:
{
  ##########################################
  ## Nix (daemon) configuration
  ##########################################
  nix = {
    settings = {
      # --- Core features -------------------------------------------------------
      experimental-features = [ "nix-command" "flakes" ];  # modern CLI + flakes
      accept-flake-config   = true;                        # allow per-flake nixConfig (see security note below)

      # --- Performance & scheduling -------------------------------------------
      auto-optimise-store = true;  # deduplicate identical store paths on add
      cores       = 0;             # 0 = use all CPU cores available
      max-jobs    = "auto";        # parallel builds (uses a sensible default)

      # --- Debug / reproducibility --------------------------------------------
      keep-outputs     = true;     # keep outputs to ease debugging / re-use
      keep-derivations = true;     # keep .drv files to inspect dependencies

      # --- (Optional) Strictness / security tuning ----------------------------
      # sandbox = true;            # default on NixOS; uncomment if I want to be explicit
      # require-sigs = true;       # require signed narinfo (typical in trusted caches)
      #
      # warn-dirty = false;        # suppress "dirty tree" warning (not recommended)
      # substituters = [ "https://cache.nixos.org" ];
      # trusted-public-keys = [ "cache.nixos.org-1:..." ];
    };

    # --- Garbage Collection ----------------------------------------------------
    # Automatic weekly GC: removes store paths older than 14 days.
    # Complements my manual `system-cleanup` alias (which does a full `-d`).
    gc = {
      automatic = true;
      dates     = "weekly";                   # run via systemd timer weekly
      options   = "--delete-older-than 14d";  # keep 2 weeks of generations
    };

    # --- (Optional) Periodic store optimisation -------------------------------
    # I already enable `auto-optimise-store` (dedup on add). If I also want
    # a periodic pass to hardlink existing duplicates across the whole store:
    # optimise.automatic = true;  # runs `nix store optimise` via timer
  };

  ##########################################
  ## nixpkgs configuration (global)
  ##########################################
  nixpkgs = {
    config = {
      allowUnfree = true;  # permit packages like unrar, NVIDIA, etc.
      # allowBroken = false;  # be explicit if I ever toggle this
    };

    # --- (Optional) Registry pinning ------------------------------------------
    # Prefer my flake inputs over the global registry/network.
    # This keeps `nix run nixpkgs#foo` deterministic for my repo.
    # registry = {
    #   nixpkgs.flake = inputs.nixpkgs;  # requires passing `inputs` via specialArgs
    # };
  };

  ##########################################
  ## (Optional) Extra: developer QoL
  ##########################################
  # If I’m collaborating or running CI, I can pre-approve users/groups for daemon ops:
  # nix.settings.trusted-users = [ "root" "samsky" ];
  #
  # If I use extra binary caches (e.g., for overlays or language ecosystems),
  # I can list them here along with their public keys:
  #
  # nix.settings = {
  #   substituters = [
  #     "https://cache.nixos.org"
  #     "https://nix-community.cachix.org"
  #   ];
  #   trusted-public-keys = [
  #     "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  #     "nix-community.cachix.org-1:7pg7fT6NOYB3KZ0Zrx3qKZ8D+z4bQpLkzsb9ZL+3p88="
  #   ];
  # };

  ##########################################
  ## Notes / trade-offs
  ##########################################
  # - accept-flake-config = true:
  #   Lets flakes inject `nixConfig` (e.g., extra substituters). This is
  #   convenient for projects I trust. For untrusted repos, I can review commits
  #   or run with `--no-accept-flake-config`.
  #
  # - keep-outputs / keep-derivations:
  #   Great for debugging and reproducibility. If disk is very tight, I can
  #   disable one or both, but I should expect fewer cache hits when iterating.
  #
  # - GC (14 days) vs my `system-cleanup` alias:
  #   This module’s GC retains ~2 weeks of generations automatically. My
  #   alias `system-cleanup` does a full delete (`-d`) and I should use it only
  #   when I’m confident I won’t need rollbacks.
}

