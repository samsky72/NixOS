# Fonts configuration.
{ config, pkgs, ... }: {
  fonts = { 
    enableDefaultFonts = true;              # Enable basic font set.
    enableGhostscriptFonts = true;          # Enable ghostscript fonts.
    fontDir.enable = true;                  # Create directory with links to all fonts.
    fonts = with pkgs; [                    # List of fonts.
      corefonts
      fira-code
      nerdfonts
    ];
    fontconfig = {
      antialias = true;                     # Enable font antialiasing.
      enable = true;                        # Build fontconfig configuration.
      subpixel = {
        lcdfilter = "default";              # Default freetype LCD filter.
        rgba = "rgb";                       # Subpixel order.
      };   
    };
  };
}
