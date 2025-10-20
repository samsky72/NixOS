# modules/office.nix
# =============================================================================
# Office suite (LibreOffice + spell/grammar tools)
#
# Scope
#   • Installs LibreOffice (fresh) system-wide
#   • Provides spell-checking via Hunspell + common dictionaries
#   • Adds LanguageTool for grammar/style checks
#   • Honors system GTK theme (works well with Stylix)
#
# Notes
#   • Use libreoffice-still for the conservative branch if preferred.
#   • LanguageTool is a standalone tool; LibreOffice can integrate it.
# =============================================================================
{ pkgs, ... }:
{
  ##########################################
  ## Applications and dictionaries
  ##########################################
  environment.systemPackages = with pkgs; [
    # Office suite
    libreoffice-fresh        # newest stable LibreOffice; switch to libreoffice-still if desired

    # Spell-checking runtime + dictionaries
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ru_RU
    # hunspellDicts.kk_KZ   # uncomment to add Kazakh dictionary if needed

    # Grammar/style checker
    languagetool
  ];

  ##########################################
  ## Optional: force GTK VCL backend for LibreOffice
  ##########################################
  # environment.variables.SAL_USE_VCL = "gtk3";
}

