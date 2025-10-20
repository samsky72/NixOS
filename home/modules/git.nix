# home/modules/git.nix
# =============================================================================
# Git (Home Manager) — user-level configuration with pragmatic, well-documented defaults
#
# Scope
#   • Establishes a predictable identity derived from the flake’s `defaultUser`
#   • Enforces linear history by default (rebase on pull) and keeps remotes tidy
#   • Wires the `delta` pager for readable, syntax-aware diffs
#   • Provides concise, task-oriented aliases
#   • Uses XDG paths (e.g., global ignores under ~/.config/git/ignore)
#
# Design notes
#   • Defaults aim to be safe and ergonomic across heterogeneous repos.
#   • Merge policy is conservative: fast-forward merges only unless explicitly overridden.
#   • Signing (GPG/SSH) is left opt-in; commented templates are provided.
#   • Comments are impersonal to simplify reuse on multiple hosts/users.
# =============================================================================
{ config, lib, defaultUser, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.git = {
    enable = true;

    ##########################################
    ## Identity (stable and declarative)
    ##
    ## Deriving from `defaultUser` keeps identity consistent with the flake.
    ## Email can be overridden per host/user if necessary.
    ##########################################
    userName  = defaultUser;
    userEmail = "${defaultUser}72@gmail.com";  # adjust if a different mailbox is preferred

    ##########################################
    ## Core behavior / ergonomics
    ##
    ## The goal is predictable histories, low noise, and good defaults for
    ## diffs, paging, and line endings. Items with material UX impact include:
    ##   - pull.rebase=true (linear history)
    ##   - merge.ff=only    (reject implicit merge commits)
    ##   - core.pager=delta (colorized, syntax-aware diffs)
    ##########################################
    extraConfig = {
      # ----- Branch & history hygiene -----------------------------------------
      init.defaultBranch      = "main";     # new repos use "main" instead of "master"
      pull.rebase             = true;       # avoid implicit merge commits on pull
      rebase.autoStash        = true;       # protect uncommitted changes during rebase
      fetch.prune             = true;       # drop branches removed on the remote
      fetch.pruneTags         = true;       # drop stale tags too
      push.autoSetupRemote    = true;       # first push creates upstream tracking
      merge.ff                = "only";     # refuse non-fast-forward merges (explicitness > convenience)
      merge.conflictStyle     = "zdiff3";   # 3-way context with base (clearer conflict blocks; git ≥ 2.35)

      # ----- Editing, coloring, and paging ------------------------------------
      core.editor             = "nvim";     # aligns with editor used elsewhere
      color.ui                = "auto";     # enable colors when stdout is a tty
      core.pager              = "delta";    # pipe all paged output through delta
      interactive.diffFilter  = "delta --color-only";  # keep interactive diffs colored

      # ----- Delta (diff viewer) tuning ---------------------------------------
      # Delta renders syntax-aware and column-aligned diffs. Side-by-side can be
      # enabled if preferred, but unified diffs remain default here for width.
      delta.navigate          = true;       # n/p to jump between diff hunks
      delta.line-numbers      = true;       # show line numbers in diffs
      delta.side-by-side      = false;      # set true to enable split view diffs
      delta.file-style        = "bold";     # emphasize file headers
      delta.hunk-header-style = "syntax";   # syntax-highlight hunk headers
      delta.minus-style       = "syntax #3f2d2d"; # removed lines: syntax + subtle red bg
      delta.plus-style        = "syntax #23342a"; # added lines: syntax + subtle green bg
      delta.zero-style        = "syntax";         # context lines

      # ----- Line endings & XDG paths -----------------------------------------
      core.autocrlf           = "input";    # store as LF; do not auto-convert on checkout
      core.excludesFile       = "${config.xdg.configHome}/git/ignore";  # XDG global ignores

      # ----- Quality-of-life defaults -----------------------------------------
      status.branch           = true;       # show branch + ahead/behind
      status.short            = false;      # use full status by default
      help.autocorrect        = 20;         # 2.0s delay before auto-correcting mistyped subcommands
      protocol.version        = 2;          # negotiate Git protocol v2 (fewer round-trips)
      advice.detachedHead     = false;      # reduce noise in detached HEAD workflows

      # ----- Performance / metadata -------------------------------------------
      gc.writeCommitGraph     = true;       # faster history walks
      fetch.writeCommitGraph  = true;       # keep commit-graph current on fetch
      index.version           = 4;          # modern index format (path compression support)

      # ----- Optional URL rewriting (disabled by default) ----------------------
      # Prefer SSH when a HTTPS GitHub URL is pasted:
      # url."ssh://git@github.com/".insteadOf = "https://github.com/";

      # ----- Optional credential caching (disabled by default) -----------------
      # In-memory cache for credentials; safer than `store` (plaintext on disk):
      # credential.helper = "cache --timeout=7200";  # 2 hours

      # ----- Optional signing (GPG or SSH) ------------------------------------
      # Uncomment to enforce signed commits/tags. For SSH signing:
      # signing.key  = "ssh-ed25519 AAAA..."; # or a GPG key ID like "ABCD1234"
      # commit.gpgSign = true;                # sign all commits by default
      # tag.gpgSign    = true;                # sign all tags by default
      # gpg.format     = "ssh";               # use SSH keys for signing
      # gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
    };

    ##########################################
    ## Aliases (short, memorable helpers)
    ##
    ## Aliases keep common tasks terse and repeatable. Each alias is designed
    ## to be mnemonic (two letters where possible) and safe (no destructive
    ## defaults unless explicitly named).
    ##########################################
    aliases = {
      # Status / navigation
      st     = "status -sb";                     # concise status with branch/changes
      br     = "branch -vv";                     # branches with upstream and last commit
      root   = "rev-parse --show-toplevel";      # absolute path to repo root

      # Diff / log
      df     = "diff";                           # unstaged changes
      dc     = "diff --cached";                  # staged changes
      lg     = "log --oneline --graph --decorate";  # compact commit graph
      last   = "log -1 --stat";                  # last commit with file stats

      # Workflow
      co     = "checkout";                       # branch/switch (legacy but still common)
      ci     = "commit";                         # commit (message via $EDITOR)
      amend  = "commit --amend --no-edit";       # fix metadata for the last commit
      fixup  = "commit --fixup";                 # create a fixup commit (use with autosquash)
      squash = "rebase -i --autosquash";         # interactive rebase w/ autosquash
      rb     = "rebase";                         # shorthand for rebase
      rbc    = "rebase --continue";              # continue rebase
      rba    = "rebase --abort";                 # abort rebase
      ps     = "push";                           # push current HEAD
      pl     = "pull --rebase";                  # pull with rebase for linear history

      # PR helper: fetch PR #N into local branch `pr-N` and check it out
      pr     = "!f(){ git fetch origin pull/$1/head:pr-$1 && git checkout pr-$1; }; f";

      # Safety / undo
      undo   = "reset --soft HEAD~1";            # uncommit but keep changes staged
      wipe   = "reset --hard";                   # hard reset (destructive; use with care)
    };

    ##########################################
    ## Extensions
    ##
    ## LFS (Large File Storage) is enabled to avoid surprises when cloning
    ## repositories that expect it; the setting is inert unless repos use LFS.
    ##########################################
    lfs.enable = true;
  };

  ##########################################
  ## Global ignore file (XDG-aware)
  ##
  ## Keeps common, untracked artifacts out of every repository. Use '*.bak' to
  ## match exact suffixes only; '*.bak*' also matches 'file.txt.bak123'.
  ##########################################
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

    # Backups / temp
    *.bak*
    *.swp
    *.swo

    # Build outputs
    dist/
    build/
    out/
    node_modules/
    target/

    # Logs & env
    *.log
    .env
    .env.*
  '';

  ##########################################
  ## Ensure `delta` is available on PATH
  ##
  ## The config above wires Git to use `delta` as the pager; installing it at
  ## the user level guarantees availability even if the system profile omits it.
  ##########################################
  home.packages = [ pkgs.delta ];
}

