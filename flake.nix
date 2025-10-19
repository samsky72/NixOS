{
  ###########################################################
  ## NixOS Configuration (flake.nix)
  ##
  ## Central configuration entry point.
  ## - Defines locale, theme catalog, and shared variables.
  ## - Passes shared values to NixOS and Home Manager via `specialArgs`.
  ## - Locale is defined here but not applied directly.
  ###########################################################

  description = "Samsky NixOS configuration";

  ###########################################################
  ## Flake inputs: channels, community modules, and tooling
  ###########################################################
  inputs = {
    # Core channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Home Manager for user-level configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Community overlays and packages
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative Neovim configuration
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional NixOS modules and utilities
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    nix-index-database.url = "github:nix-community/nix-index-database";
    stylix.url = "github:danth/stylix";
    nix-colors.url = "github:misterio77/nix-colors";

    # Repo tooling and flake utilities
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  ###########################################################
  ## Flake outputs
  ###########################################################
  outputs = inputs@{
    self, nixpkgs, nixpkgs-stable,
    home-manager, nur, nixvim,
    impermanence, sops-nix,
    nix-index-database, stylix, nix-colors,
    treefmt-nix, flake-parts, ...
  }:
  let
    #########################################################
    ## Shared variables and helper definitions
    #########################################################

    system = "x86_64-linux";
    lib = inputs.nixpkgs.lib;
    stateVersion = "24.05";

    # Fonts and users
    font = "JetBrainsMono Nerd Font";
    users = { guest = "guest"; samsky = "samsky"; };
    defaultUser = users.samsky;

    # Locale and keyboard layout definitions
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
      };
    };

    # Optional secrets configuration (used if file exists)
    secretsPath = ./secrets/secrets.yaml;
    haveSecrets = builtins.pathExists secretsPath;

    #########################################################
    ## Theme catalog
    ## - Contains all nix-colors schemes and short aliases
    ## - Provides `resolve` for resolving aliases to canonical names
    #########################################################
    themeCatalog = rec {
      all = [
        "3024" "apathy" "apprentice" "ashes"
        "atelier-cave" "atelier-cave-light" "atelier-dune" "atelier-dune-light"
        # ... (list truncated for brevity)
        "woodland" "xcode-dusk" "zenbones" "zenburn"
      ];

      themeAliases = {
        # Tokyonight family
        tokyo = "tokyo-night-dark";
        tokyoDark = "tokyo-night-dark";
        tokyoLight = "tokyo-night-light";
        tokyoStorm = "tokyo-night-storm";
        tokyoTerm = "tokyo-night-terminal-dark";
        tokyoTermLight = "tokyo-night-terminal-light";
        tokyoTermStorm = "tokyo-night-terminal-storm";
        tokyoCity = "tokyo-city-dark";
        tokyoCityLight = "tokyo-city-light";
        tokyoCityTerm = "tokyo-city-terminal-dark";
        tokyoCityTermLight = "tokyo-city-terminal-light";
        tokyodark = "tokyodark";
        tokyodarkTerm = "tokyodark-terminal";

        # Gruvbox variants
        gruvbox = "gruvbox-dark-medium";
        gruvboxSoft = "gruvbox-dark-soft";
        gruvboxHard = "gruvbox-dark-hard";
        gruvboxPale = "gruvbox-dark-pale";
        gruvboxLight = "gruvbox-light-medium";
        gruvboxLightSoft = "gruvbox-light-soft";
        gruvboxLightHard = "gruvbox-light-hard";

        # Gruvbox Material
        gruvMat = "gruvbox-material-dark-medium";
        gruvMatSoft = "gruvbox-material-dark-soft";
        gruvMatHard = "gruvbox-material-dark-hard";
        gruvMatLight = "gruvbox-material-light-medium";
        gruvMatLightSoft = "gruvbox-material-light-soft";
        gruvMatLightHard = "gruvbox-material-light-hard";

        # Rose Pine family
        rosePine = "rose-pine";
        roseMoon = "rose-pine-moon";
        roseDawn = "rose-pine-dawn";

        # Catppuccin family
        catppuccin = "catppuccin-mocha";
        catMocha = "catppuccin-mocha";
        catFrappe = "catppuccin-frappe";
        catLatte = "catppuccin-latte";
        catMacchiato = "catppuccin-macchiato";

        # Material and related
        material = "material";
        matPalenight = "material-palenight";
        matDarker = "material-darker";
        matLighter = "material-lighter";
        matVivid = "material-vivid";

        # Selenized family
        selenizedBlack = "selenized-black";
        selenizedDark = "selenized-dark";
        selenizedLight = "selenized-light";
        selenizedWhite = "selenized-white";

        # Horizon family
        horizon = "horizon-dark";
        horizonLight = "horizon-light";
        horizonTerm = "horizon-terminal-dark";
        horizonTermLight = "horizon-terminal-light";

        # Solarized / Solarflare
        solarDark = "solarized-dark";
        solarLight = "solarized-light";
        solarflare = "solarflare";
        solarflareLight = "solarflare-light";

        # Oxocarbon
        oxoDark = "oxocarbon-dark";
        oxoLight = "oxocarbon-light";

        # General popular themes
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
        primerDim = "primer-dark-dimmed";
        primerLight = "primer-light";
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

      # Resolver for alias or direct theme names
      resolve = key:
        if builtins.hasAttr key themeAliases then builtins.getAttr key themeAliases
        else if lib.elem key all then key
        else throw "Unknown theme key '${key}'.";
    };

    # Selected theme
    themeKey = "tokyo";

    # Derived theme data
    base16Name = themeCatalog.resolve themeKey;
    base16Scheme = lib.getAttr base16Name inputs.nix-colors.colorSchemes;
    colorScheme = base16Scheme;

    # Utility: search for themes matching a substring
    findSchemes = term:
      builtins.filter (n: lib.strings.hasInfix term n) themeCatalog.all;

    # Stylix font helper
    stylixMonospace = pkgs: {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = font;
    };

    # Base nixpkgs configuration
    nixpkgsBase = {
      overlays = [ nur.overlays.default ];
      config.allowUnfree = true;
    };

    # Shared Nix settings
    nixCommonModule = {
      nixpkgs = nixpkgsBase;
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      programs.nix-index.enable = true;
      programs.nix-index-database.comma.enable = true;
    };

    # Home Manager user mapping
    hmUsers = {
      ${users.samsky} = import ./home/users/samsky/home.nix;
      # ${users.guest} = import ./home/users/guest/home.nix;
    };

    # Hosts and systems
    myHosts = [ "zephyrus" ];
    mySystems = [ system ];

    # Pinned nixpkgs constructor
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        inherit (nixpkgsBase) overlays;
        config = { allowUnfree = nixpkgsBase.config.allowUnfree; };
      };

    # Shared special arguments
    specialArgsBase = {
      inherit inputs stateVersion defaultUser font users locale;
      inherit themeCatalog themeKey base16Name base16Scheme colorScheme;
    };

    #########################################################
    ## Host configuration generator
    #########################################################
    mkHost = hostName: lib.nixosSystem {
      inherit system;

      # Shared arguments for modules
      specialArgs = specialArgsBase // { inherit hostName; };

      modules =
        [
          # Host-specific configuration (includes hardware)
          ./hosts/${hostName}/configuration.nix

          # Common Nix settings
          nixCommonModule

          # Stylix theming
          stylix.nixosModules.stylix
          ({ pkgs, ... }: {
            stylix.enable = true;
            stylix.base16Scheme = base16Scheme;
            stylix.fonts.monospace = stylixMonospace pkgs;
          })

          # Declarative Neovim configuration
          nixvim.nixosModules.nixvim

          # Impermanence module
          impermanence.nixosModules.impermanence

          # Home Manager integration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgsBase // { inherit hostName; };
            home-manager.sharedModules = [ inputs.nixvim.homeModules.nixvim ];
            home-manager.users = hmUsers;
          }

          # Prebuilt nix-index database
          nix-index-database.nixosModules.nix-index
        ]
        # Conditional inclusion of SOPS
        ++ lib.optionals haveSecrets [
          sops-nix.nixosModules.sops
          { sops.defaultSopsFile = secretsPath; }
        ];
    };
  in
  ###########################################################
  ## Flake-parts integration
  ###########################################################
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = mySystems;

    perSystem = { pkgs, system, ... }:
    let
      myPkgs = pkgsFor system;
    in {
      # Formatter for `nix fmt`
      formatter = myPkgs.nixfmt-rfc-style;

      # Development shell
      devShells.default = myPkgs.mkShell {
        packages = with myPkgs; [
          git
          nixfmt-rfc-style
          just
        ];
      };

      # Treefmt check for CI
      checks.treefmt = treefmt-nix.lib.mkSimple {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };
    };

    # Exported NixOS configurations
    flake = {
      nixosConfigurations = lib.genAttrs myHosts (hn: mkHost hn);
    };
  };
}

