# home/modules/git.nix
# =============================================================================
# Git (Home Manager) — user-level config with sane, documented defaults.
#
# Goals:
# - Pull identity from the flake’s `defaultUser`.
# - Clean history by default (rebase pulls, prune stale refs).
# - Useful aliases and readable diffs (delta).
# - Editor set to Neovim to match the rest of my system.
# - Portable: all paths XDG-aware; easy to override per host/user if needed.
# =============================================================================
{ config, lib, defaultUser, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.git = {
    enable = true;

    ##########################################
    ## Identity (from flake defaultUser)
    ##########################################
    userName  = defaultUser;
    userEmail = "${defaultUser}72@gmail.com";  # change if needed

    ##########################################
    ## Behavior / ergonomics
    ##########################################
    # Keep pulls linear, keep the tree tidy, and use Neovim everywhere.
    extraConfig = {
      init.defaultBranch   = "main";        # use 'main' for new repos
      pull.rebase          = true;          # rebase on pull (linear history)
      rebase.autoStash     = true;          # stash uncommitted changes before rebase
      fetch.prune          = true;          # drop deleted remote branches on fetch
      push.autoSetupRemote = true;          # 'git push' creates upstream on first push

      color.ui             = "auto";        # colorized CLI output
      core.editor          = "nvim";        # match system default editor

      # Respect XDG for global ignore file (declared below).
      core.excludesFile    = "${config.xdg.configHome}/git/ignore";

      # Safer line endings across platforms (no CRLF surprises).
      core.autocrlf        = "input";       # convert CRLF→LF on commit; leave files as-is on checkout

      # Show more helpful status by default.
      status.branch        = true;
      status.short         = false;

      # Use delta for nicer diffs and paging (configure delta below).
      core.pager               = "delta";
      interactive.diffFilter   = "delta --color-only";
      delta.navigate           = true;    # n/p to move between diff sections
      delta.line-numbers       = true;
      delta.side-by-side       = false;   # set to true if I prefer split view
      delta.minus-style        = "syntax #3f2d2d";
      delta.plus-style         = "syntax #23342a";
      delta.zero-style         = "syntax";
      delta.file-style         = "bold";
      delta.hunk-header-style  = "syntax";

      # (Optional) Prefer SSH for GitHub if I paste HTTPS URLs.
      # url."ssh://git@github.com/".insteadOf = "https://github.com/";

      # (Optional) Cache credentials in-memory for a while (safer than 'store').
      # credential.helper = "cache --timeout=7200";  # 2 hours
    };

    ##########################################
    ## Aliases (shortcuts I actually use)
    ##########################################
    aliases = {
      co = "checkout";
      br = "branch -vv";
      ci = "commit";
      st = "status -sb";
      df = "diff";
      dc = "diff --cached";
      lg = "log --oneline --graph --decorate";
      last = "log -1 --stat";
      amend = "commit --amend --no-edit";
      fixup = "commit --fixup";
      squash = "rebase -i --autosquash";
      rb = "rebase";
      rbc = "rebase --continue";
      rba = "rebase --abort";
      ps = "push";
      pl = "pull --rebase";
      pr = "!git fetch origin pull/$1/head:pr-$1 && git checkout pr-$1"; # usage: git pr 123
      undo = "reset --soft HEAD~1";
      wipe = "reset --hard";
    };

    ##########################################
    ## Extensions (optional but useful)
    ##########################################
    lfs.enable = true;   # Large File Storage (no-op unless repo enables LFS)

    # Signing (PGP/SSH) — disabled by default; uncomment to enable:
    # signing = {
    #   key = "YOUR_KEY_ID_OR_SSH_KEY";  # e.g., "ABCD1234" or "ssh-ed25519 AAAA..."
    #   signByDefault = true;
    # };
  };

  ##########################################
  ## Global ignore file (XDG path)
  ##########################################
  # Keep common junk out of all repositories.
  # Added: '*.bak*' to ignore editor/backup artifacts like 'file.txt.bak'
  # and 'file.bak123'. If you only want exact '.bak' endings, use '*.bak' instead.
  xdg.configFile."git/ignore".text = ''
    # OS / editors
    .DS_Store
    Thumbs.db
    *~
    .idea/
    .vscode/
    .history/
    .direnv/
    .envrc

    # backups / temp
    *.bak*
    *.swp
    *.swo

    # build outputs
    dist/
    build/
    out/
    node_modules/
    target/

    # logs & env
    *.log
    .env
    .env.*
  '';

  ##########################################
  ## Optional: delta binary via HM packages
  ##########################################
  # If delta isn't already on PATH system-wide, add it here.
  home.packages = [ pkgs.delta ];
}

