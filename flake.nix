{
  ############################################
  ## Samsky NixOS configuration (flake.nix)
  ## - I define `locale` + a theme catalog here
  ## - I pass them via specialArgs to NixOS & HM
  ## - I do NOT apply locale inline in the flake
  ############################################
  description = "Samsky NixOS configuration";

  ############################################
  ## Flake inputs (channels, tools, theming)
  ############################################
  inputs = {
    # --- Core channels ---
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    # --- User-level config manager ---
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Community overlay/packages ---
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Declarative Neovim as a NixOS/HM module ---
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Optional modules/tools ---
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    nix-index-database.url = "github:nix-community/nix-index-database";
    stylix.url = "github:danth/stylix";
    nix-colors.url = "github:misterio77/nix-colors";

    # --- Repo tooling ---
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  ############################################
  ## Flake outputs
  ############################################
  outputs = inputs@{
    self, nixpkgs, nixpkgs-stable,
    home-manager, nur, nixvim,
    impermanence, sops-nix,
    nix-index-database, stylix, nix-colors,
    treefmt-nix, flake-parts, ...
  }:
  let
    ########################################
    ## Shared variables & helpers
    ########################################

    system = "x86_64-linux";
    lib = nixpkgs.lib;
    stateVersion = "24.05";

    # Fonts / users
    font = "JetBrainsMono Nerd Font";
    users = { guest = "guest"; samsky = "samsky"; };
    defaultUser = users.samsky;

    # Centralized locale/time/keyboard (I only pass this through)
    locale = {
      timeZone = "Asia/Oral";
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [
        "en_US.UTF-8/UTF-8"
        "kk_KZ.UTF-8/UTF-8"
        "ru_RU.UTF-8/UTF-8"
      ];
      xkb = {
        layout = "us,ru";
        options = "grp:win_space_toggle";
        # model = ""; variant = "";
      };
    };

    # Secrets path (optional) — SOPS module is activated only if this file exists
    secretsPath = ./secrets/secrets.yaml;
    haveSecrets = builtins.pathExists secretsPath;

    # ---------------- THEME CATALOG (full list + rich themeAliases) -------------
    themeCatalog = rec {
      # Canonical nix-colors scheme names (as provided by nix-colors)
      all = [
        "3024" "apathy" "apprentice" "ashes"
        "atelier-cave" "atelier-cave-light" "atelier-dune" "atelier-dune-light"
        "atelier-estuary" "atelier-estuary-light" "atelier-forest" "atelier-forest-light"
        "atelier-heath" "atelier-heath-light" "atelier-lakeside" "atelier-lakeside-light"
        "atelier-plateau" "atelier-plateau-light" "atelier-savanna" "atelier-savanna-light"
        "atelier-seaside" "atelier-seaside-light" "atelier-sulphurpool" "atelier-sulphurpool-light"
        "atlas" "ayu-dark" "ayu-light" "ayu-mirage" "bespin"
        "black-metal" "black-metal-bathory" "black-metal-burzum" "black-metal-dark-funeral"
        "black-metal-gorgoroth" "black-metal-immortal" "black-metal-khold" "black-metal-marduk"
        "black-metal-mayhem" "black-metal-nile" "black-metal-venom"
        "blueforest" "blueish" "brewer" "bright" "brogrammer"
        "brushtrees" "brushtrees-dark" "caroline"
        "catppuccin-frappe" "catppuccin-latte" "catppuccin-macchiato" "catppuccin-mocha"
        "chalk" "circus" "classic-dark" "classic-light" "codeschool" "colors" "cupcake" "cupertino"
        "da-one-black" "da-one-gray" "da-one-ocean" "da-one-paper" "da-one-sea" "da-one-white"
        "danqing" "danqing-light" "darcula" "darkmoss" "darktooth" "darkviolet" "decaf"
        "default-dark" "default-light" "dirtysea" "dracula"
        "edge-dark" "edge-light" "eighties" "embers" "emil"
        "equilibrium-dark" "equilibrium-gray-dark" "equilibrium-gray-light" "equilibrium-light"
        "eris" "espresso" "eva" "eva-dim" "evenok-dark"
        "everforest" "everforest-dark-hard" "flat" "framer" "fruit-soda" "gigavolt" "github"
        "google-dark" "google-light" "gotham" "grayscale-dark" "grayscale-light" "greenscreen"
        "gruber"
        "gruvbox-dark-hard" "gruvbox-dark-medium" "gruvbox-dark-pale" "gruvbox-dark-soft"
        "gruvbox-light-hard" "gruvbox-light-medium" "gruvbox-light-soft"
        "gruvbox-material-dark-hard" "gruvbox-material-dark-medium" "gruvbox-material-dark-soft"
        "gruvbox-material-light-hard" "gruvbox-material-light-medium" "gruvbox-material-light-soft"
        "hardcore" "harmonic16-dark" "harmonic16-light" "heetch" "heetch-light" "helios" "hopscotch"
        "horizon-dark" "horizon-light" "horizon-terminal-dark" "horizon-terminal-light"
        "humanoid-dark" "humanoid-light" "ia-dark" "ia-light" "icy" "irblack" "isotope"
        "kanagawa" "katy" "kimber" "lime" "macintosh" "marrakesh"
        "materia" "material" "material-darker" "material-lighter" "material-palenight" "material-vivid"
        "mellow-purple" "mexico-light" "mocha" "monokai" "mountain" "nebula" "nord" "nova"
        "ocean" "oceanicnext" "one-light" "onedark" "outrun-dark"
        "oxocarbon-dark" "oxocarbon-light" "pandora" "papercolor-dark" "papercolor-light"
        "paraiso" "pasque" "phd" "pico" "pinky" "pop" "porple"
        "primer-dark" "primer-dark-dimmed" "primer-light"
        "purpledream" "qualia" "railscasts" "rebecca"
        "rose-pine" "rose-pine-dawn" "rose-pine-moon"
        "sagelight" "sakura" "sandcastle"
        "selenized-black" "selenized-dark" "selenized-light" "selenized-white"
        "seti" "shades-of-purple" "shadesmear-dark" "shadesmear-light" "shapeshifter"
        "silk-dark" "silk-light" "snazzy"
        "solarflare" "solarflare-light" "solarized-dark" "solarized-light"
        "spaceduck" "spacemacs" "standardized-dark" "standardized-light" "stella" "still-alive"
        "summercamp" "summerfruit-dark" "summerfruit-light"
        "synth-midnight-dark" "synth-midnight-light" "tango" "tarot" "tender"
        "tokyo-city-dark" "tokyo-city-light" "tokyo-city-terminal-dark" "tokyo-city-terminal-light"
        "tokyo-night-dark" "tokyo-night-light" "tokyo-night-storm"
        "tokyo-night-terminal-dark" "tokyo-night-terminal-light" "tokyo-night-terminal-storm"
        "tokyodark" "tokyodark-terminal"
        "tomorrow" "tomorrow-night" "tomorrow-night-eighties" "tube" "twilight"
        "unikitty-dark" "unikitty-light" "unikitty-reversible"
        "uwunicorn" "vice" "vulcan"
        "windows-10" "windows-10-light" "windows-95" "windows-95-light"
        "windows-highcontrast" "windows-highcontrast-light"
        "windows-nt" "windows-nt-light"
        "woodland" "xcode-dusk" "zenbones" "zenburn"
      ];

      # Short, memorable aliases → canonical names
      themeAliases = {
        # --- Tokyonight family ---
        tokyo          = "tokyo-night-dark";
        tokyoDark      = "tokyo-night-dark";
        tokyoLight     = "tokyo-night-light";
        tokyoStorm     = "tokyo-night-storm";
        tokyoTerm      = "tokyo-night-terminal-dark";
        tokyoTermLight = "tokyo-night-terminal-light";
        tokyoTermStorm = "tokyo-night-terminal-storm";
        tokyoCity      = "tokyo-city-dark";
        tokyoCityLight = "tokyo-city-light";
        tokyoCityTerm  = "tokyo-city-terminal-dark";
        tokyoCityTermLight = "tokyo-city-terminal-light";
        tokyodark      = "tokyodark";
        tokyodarkTerm  = "tokyodark-terminal";

        # --- Gruvbox family ---
        gruvbox          = "gruvbox-dark-medium";
        gruvboxSoft      = "gruvbox-dark-soft";
        gruvboxHard      = "gruvbox-dark-hard";
        gruvboxPale      = "gruvbox-dark-pale";
        gruvboxLight     = "gruvbox-light-medium";
        gruvboxLightSoft = "gruvbox-light-soft";
        gruvboxLightHard = "gruvbox-light-hard";

        # Gruvbox Material
        gruvMat          = "gruvbox-material-dark-medium";
        gruvMatSoft      = "gruvbox-material-dark-soft";
        gruvMatHard      = "gruvbox-material-dark-hard";
        gruvMatLight     = "gruvbox-material-light-medium";
        gruvMatLightSoft = "gruvbox-material-light-soft";
        gruvMatLightHard = "gruvbox-material-light-hard";

        # --- Rose Pine family ---
        rosePine = "rose-pine";
        roseMoon = "rose-pine-moon";
        roseDawn = "rose-pine-dawn";

        # --- Catppuccin family ---
        catppuccin   = "catppuccin-mocha";
        catMocha     = "catppuccin-mocha";
        catFrappe    = "catppuccin-frappe";
        catLatte     = "catppuccin-latte";
        catMacchiato = "catppuccin-macchiato";

        # --- Material family ---
        material     = "material";
        matPalenight = "material-palenight";
        matDarker    = "material-darker";
        matLighter   = "material-lighter";
        matVivid     = "material-vivid";

        # --- Selenized family ---
        selenizedBlack = "selenized-black";
        selenizedDark  = "selenized-dark";
        selenizedLight = "selenized-light";
        selenizedWhite = "selenized-white";

        # --- Horizon family ---
        horizon         = "horizon-dark";
        horizonLight    = "horizon-light";
        horizonTerm     = "horizon-terminal-dark";
        horizonTermLight= "horizon-terminal-light";

        # --- Solarized/Solarflare ---
        solarDark    = "solarized-dark";
        solarLight   = "solarized-light";
        solarflare   = "solarflare";
        solarflareLight = "solarflare-light";

        # --- Oxocarbon ---
        oxoDark  = "oxocarbon-dark";
        oxoLight = "oxocarbon-light";

        # --- “Greatest hits” ---
        nord = "nord";
        dracula = "dracula";
        onedark = "onedark";
        oneLight = "one-light";
        monokai = "monokai";
        kanagawa = "kanagawa";
        everforest = "everforest";
        everforestHard = "everforest-dark-hard";
        snazzy = "snazzy";
        zenburn = "zenburn";
        zenbones = "zenbones";
        gotham = "gotham";
        ocean = "ocean";
        oceanicnext = "oceanicnext";
        spaceduck = "spaceduck";
        spacemacs = "spacemacs";
        tomorrow = "tomorrow";
        tomorrowNight = "tomorrow-night";
        tomorrow80s = "tomorrow-night-eighties";
        primerDark = "primer-dark";
        primerDim  = "primer-dark-dimmed";
        primerLight= "primer-light";
        github = "github";
        googleDark = "google-dark";
        googleLight = "google-light";
        xcodeDusk = "xcode-dusk";
        tango = "tango";
        tender = "tender";
        twilight = "twilight";
        rebecca = "rebecca";
        stillAlive = "still-alive";
      };

      # Resolver: short key → canonical name, or accept exact name from `all`
      resolve = key:
        if builtins.hasAttr key themeAliases then builtins.getAttr key themeAliases
        else if lib.elem key all then key
        else throw "Unknown theme key or scheme '${key}'. \
Try a key from themeCatalog.themeAliases or a name from themeCatalog.all.";
    };

    # Choose the theme by SHORT KEY (preferred) or exact name from `all`
    themeKey = "tokyo";  # ← change me

    # Final name + scheme derived from the catalog
    base16Name   = themeCatalog.resolve themeKey;
    base16Scheme = lib.getAttr base16Name inputs.nix-colors.colorSchemes;

    # Back-compat alias some modules still expect
    colorScheme = base16Scheme;

    # Helper to grep scheme names at eval time (dev convenience)
    findSchemes = term:
      builtins.filter (n: lib.strings.hasInfix term n) themeCatalog.all;

    # Fonts helper for Stylix
    stylixMonospace = pkgs: {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = font;
    };

    # nixpkgs base (NUR overlay + allow unfree)
    nixpkgsBase = {
      overlays = [ nur.overlays.default ];
      config.allowUnfree = true;
    };

    # Common Nix options shared across hosts
    nixCommonModule = {
      nixpkgs = nixpkgsBase;
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      programs.nix-index.enable = true;
      programs.nix-index-database.comma.enable = true;
    };

    # Home-Manager users mapping (imports only)
    hmUsers = {
      ${users.samsky} = import ./home/users/samsky/home.nix;
      # ${users.guest}  = import ./home/users/guest/home.nix;
    };

    # Hosts list and systems list (easy to scale)
    myHosts = [ "zephyrus" ];
    mySystems = [ system ];

    # Pinned pkgs constructor (with NUR + unfree) for perSystem tooling
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        inherit (nixpkgsBase) overlays;
        config = { allowUnfree = nixpkgsBase.config.allowUnfree; };
      };

    # Unified special args for BOTH NixOS and Home Manager
    specialArgsBase = {
      inherit inputs stateVersion defaultUser font users locale;
      inherit themeCatalog themeKey base16Name base16Scheme colorScheme;
    };

    ########################################
    ## mkHost: materialize a NixOS config for a given host
    ########################################
    mkHost = hostName: lib.nixosSystem {
      inherit system;

      # Pass shared args (plus hostName) into all modules (NixOS + HM)
      specialArgs = specialArgsBase // { inherit hostName; };

      modules =
        [
          #####################################
          ## Per-host NixOS configuration
          ## (this file should import ./hardware-configuration.nix)
          #####################################
          ./hosts/${hostName}/configuration.nix

          #####################################
          ## Common nixpkgs/Nix/nix-index settings
          #####################################
          nixCommonModule

          #####################################
          ## Theming via Stylix (Base16 scheme + font)
          #####################################
          stylix.nixosModules.stylix
          ({ pkgs, ... }: {
            stylix.enable = true;
            stylix.base16Scheme = base16Scheme;      # ← from resolver above
            stylix.fonts.monospace = stylixMonospace pkgs;
          })

          #####################################
          ## Declarative Neovim (nixvim)
          #####################################
          nixvim.nixosModules.nixvim

          #####################################
          ## Impermanence (configure /persist in host file)
          #####################################
          impermanence.nixosModules.impermanence

          #####################################
          ## Home Manager integration (per-user entries)
          #####################################
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # Reuse the same special args for HM (includes theme bits)
            home-manager.extraSpecialArgs = specialArgsBase // { inherit hostName; };

            # Keep only modules I need; Stylix HM module comes from system Stylix automatically
            home-manager.sharedModules = [
              inputs.nixvim.homeModules.nixvim
            ];

            # Each user's HM config lives under home/users/<user>/home.nix
            home-manager.users = hmUsers;
          }

          #####################################
          ## nix-index prebuilt DB + `comma` UX
          #####################################
          nix-index-database.nixosModules.nix-index
        ]
        #####################################
        ## Conditionally include SOPS (only if secrets file exists)
        #####################################
        ++ lib.optionals haveSecrets [
          sops-nix.nixosModules.sops
          { sops.defaultSopsFile = secretsPath; }
        ];
    };
  in
  ############################################
  ## Top-level via flake-parts
  ############################################
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = mySystems;

    perSystem = { pkgs, system, ... }:
    let
      myPkgs = pkgsFor system;  # pinned pkgs with NUR + unfree
    in {
      ########################################
      ## Formatter for `nix fmt`
      ########################################
      formatter = myPkgs.nixfmt-rfc-style;

      ########################################
      ## Dev shell for repo work
      ########################################
      devShells.default = myPkgs.mkShell {
        packages = with myPkgs; [
          git
          nixfmt-rfc-style
          just
        ];
      };

      ########################################
      ## treefmt-nix as a check (optional CI)
      ########################################
      checks.treefmt = treefmt-nix.lib.mkSimple {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };
    };

    ########################################
    ## Publish NixOS hosts at top level
    ########################################
    flake = {
      nixosConfigurations = lib.genAttrs myHosts (hn: mkHost hn);
    };
  };
}

