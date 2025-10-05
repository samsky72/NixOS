{ pkgs, ... }:
{
  ##########################################
  ## Base System Packages
  ##
  ## This defines globally available CLI tools
  ## and development utilities for all users.
  ##########################################
  environment.systemPackages = with pkgs; [
    ##########################################
    # Core utilities
    ##########################################
    git              # Version control
    curl             # Fetch URLs / APIs
    wget             # Simple downloader
    vim              # Fallback text editor
    gcc              # C/C++ compiler (used by Neovim plugins, etc.)
    gnumake          # Essential build tool

    ##########################################
    # Nix tooling
    ##########################################
    nixpkgs-fmt      # Formatter for .nix files
    nix-tree         # Visualize dependency graphs
    nix-output-monitor # Better nix build progress display
    nix-diff         # Diff between derivations

    ##########################################
    # System diagnostics
    ##########################################
    htop             # Process monitor
    lsof             # List open files
    pciutils         # lspci, hardware info
    usbutils         # lsusb, USB info
    psmisc           # killall, pstree, etc.
    file             # Identify file types
    which            # Locate executables

    ##########################################
    # Quality of life / dev
    ##########################################
    bat              # cat replacement with syntax highlighting
    ripgrep          # fast recursive search
    fd               # better `find`
    tree             # directory tree view
    zip unzip        # archive tools
    jq               # JSON manipulation
  ];
}

