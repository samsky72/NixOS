# XDG configuration.
let
  user = "samsky";
in 
{ config, ... }: {
  xdg = {
    enable = true;
    cacheHome = "/home/" + user + "/.cache";
    configHome = "/home/" + user + "/.config";
    dataHome = "/home/" + user + "/.local/share";
    mimeApps = {
      defaultApplications = {
        "video/x-matroska" = "smplayer.desktop";
      };
      enable = true;
    };
    stateHome = "/home/" + user + "/.local/state";
    userDirs = {
      enable = true;
      desktop = "/home/" + user + "/Desktop";
      documents = "/home/" + user + "/Documents";
      download = "/home/" + user + "/Downloads";
      music = "/home/" + user + "/Music";
      pictures = "/home/" + user + "/Pictures";
      publicShare = "/home/" + user + "/Public";
      templates = "/home/" + user + "/Templates";
      videos = "/home/" + user + "/Videos";
    };
  };
}
