# Home manager confgiurations.
{ config, inputs, stateVersion, ...}: {

  imports = [
    inputs.nixvim.homeManagerModules.nixvim       # NixVim home managers module.
  ];

  home.stateVersion = stateVersion;
}
