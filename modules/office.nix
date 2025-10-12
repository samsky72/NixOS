# modules/office.nix
{ pkgs, ... }:
{
  ##########################################
  ## Office Suite (LibreOffice + tools)
  ##
  ## - I install LibreOffice (fresh) system-wide.
  ## - I add spell-checking (hunspell + common dictionaries).
  ## - I add LanguageTool for grammar/style checks.
  ## - LibreOffice follows my GTK theme (works well with Stylix).
  ##########################################

  environment.systemPackages = with pkgs; [
    # Main suite (fresh = newest stable; use libreoffice-still for conservative)
    libreoffice-fresh

    # Spell-checking runtime + dictionaries I use
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ru_RU
    # Add more if needed, e.g.:
    # hunspellDicts.de_DE
    # hunspellDicts.fr_FR

    # Optional: grammar/style checker (runs standalone; LO can use it too)
    languagetool
  ];

  # Optional (only if I want LO to always use GTK3 VCL explicitly):
  # environment.variables.SAL_USE_VCL = "gtk3";
}

