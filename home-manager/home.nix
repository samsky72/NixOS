# Home manager confgiurations.
{ config, inputs, stateVersion, userName, ...}: {

  imports = [
    inputs.nixvim.homeManagerModules.nixvim       # NixVim home managers module.
  ];

  # Define default home variables.
  home = {
    homeDirectory = "/home/${userName}";
    stateVersion = stateVersion;
    username = userName;
  };
}
