# home/modules/git.nix
# =============================================================================
# Git (Home Manager) — user-level configuration with current HM schema.
#
# Intent
#   • Configure identity, behavior, aliases, and pager using the canonical
#     `programs.git.settings` attribute set (no deprecated keys).
#   • Keep a global ignore file under XDG config.
#   • Provide delta as a pager for readable diffs.
#
# Notes
#   • Identity is sourced from the flake’s `defaultUser`.
#   • All options below are standard git config keys; structure mirrors `git config`.
# =============================================================================
{ config, lib, defaultUser, pkgs, ... }:

{
  programs.git = {
    enable = true;  # enable Git configuration under Home Manager

    # All Git configuration lives under `settings` (replaces userName/userEmail/extraConfig/aliases).
    settings = {
      ##########################################################################
      ## Identity
      ##########################################################################
      user.name  = defaultUser;                            # author/committer name
      user.email = "${defaultUser}72@gmail.com";           # author/committer email

      ##########################################################################
      ## Behavior / ergonomics
      ##########################################################################
      init.defaultBranch        = "main";                  # default branch for new repos
      pull.rebase               = true;                    # rebase instead of merge on pull
      rebase.autoStash          = true;                    # stash and re-apply local changes on rebase
      fetch.prune               = true;                    # remove remote-tracking refs that vanished upstream
      push.autoSetupRemote      = true;                    # first push sets upstream automatically

      color.ui                  = "auto";                  # colorize CLI output when appropriate
      core.editor               = "nvim";                  # default editor invoked by git
      core.excludesFile         = "${config.xdg.configHome}/git/ignore";  # global ignore path (declared below)
      core.autocrlf             = "input";                 # normalize CRLF → LF on commit (leave files as-is on checkout)

      status.branch             = true;                    # show branch/commit info in `git status`
      status.short              = false;                   # keep full `git status` output (not `-s` by default)

      ##########################################################################
      ## Delta (pager) — styled, navigable diffs
      ##########################################################################
      core.pager                = "delta";                 # route all paging through delta
      interactive.diffFilter    = "delta --color-only";    # keep interactive add colored
      delta.navigate            = true;                    # enable n/p section navigation
      delta.line-numbers        = true;                    # show line numbers in diffs
      delta.side-by-side        = false;                   # unified view (set true for split view)
      delta.minus-style         = "syntax #3f2d2d";        # removed line styling (syntax + bg hint)
      delta.plus-style          = "syntax #23342a";        # added line styling   (syntax + bg hint)
      delta.zero-style          = "syntax";                # context lines styling
      delta.file-style          = "bold";                  # filename header emphasis
      delta.hunk-header-style   = "syntax";                # hunk header styling

      ##########################################################################
      ## Aliases (shortcuts)
      ##########################################################################
      alias = {
        co     = "checkout";                               # change branches or restore files
        br     = "branch -vv";                             # list branches with upstream/last commit
        ci     = "commit";                                 # create a commit
        st     = "status -sb";                             # concise status (short+branch)
        df     = "diff";                                   # working tree vs index diff
        dc     = "diff --cached";                          # index vs HEAD diff
        lg     = "log --oneline --graph --decorate";       # compact commit graph view
        last   = "log -1 --stat";                          # last commit with file stats
        amend  = "commit --amend --no-edit";               # amend without changing message
        fixup  = "commit --fixup";                         # create fixup commit for autosquash
        squash = "rebase -i --autosquash";                 # interactive rebase with fixup/squash applied
        rb     = "rebase";                                 # shorthand for rebase
        rbc    = "rebase --continue";                      # continue rebase
        rba    = "rebase --abort";                         # abort rebase
        ps     = "push";                                   # push
        pl     = "pull --rebase";                          # pull with rebase (explicit)
        pr     = "!git fetch origin pull/$1/head:pr-$1 && git checkout pr-$1";  # fetch+checkout PR: `git pr 123`
        undo   = "reset --soft HEAD~1";                    # undo last commit, keep changes staged
        wipe   = "reset --hard";                           # hard reset working tree/index to HEAD
      };

      ##########################################################################
      ## Optional preferences (kept commented; enable as needed)
      ##########################################################################
      # url."ssh://git@github.com/".insteadOf = "https://github.com/";  # prefer SSH even when pasting HTTPS
      # credential.helper = "cache --timeout=7200";                      # in-memory credential cache (2h)
    };

    # Large File Storage (no effect unless a repo enables LFS filters).
    lfs.enable = true;
  };

  ##############################################################################
  ## Global ignore file (XDG path)
  ##
  ## Rationale:
  ##   Keeps common transient artifacts out of all repositories. Patterns below
  ##   are intentionally modest; extend locally as needed.
  ##############################################################################
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

  ##############################################################################
  ## Helper binaries
  ##
  ## Rationale:
  ##   `core.pager = delta` requires the delta executable on PATH. It is added
  ##   here to ensure availability even if the system profile omits it.
  ##############################################################################
  home.packages = [ pkgs.delta ];
}

