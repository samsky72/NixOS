# Programs with SUID wrappers.
{ config, pkgs,...} : {
  programs = {
    adb.enable = true;
    atop = {
      enable = true;
      netatop.enable = true;
      atopgpu.enable = true;
    };
    firefox.enable = true;
    git.enable = true;
    htop.enable= true;
    traceroute.enable = true;
    tmux.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
    };
  };
}   
