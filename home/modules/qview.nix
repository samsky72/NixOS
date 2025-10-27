# home/modules/qview.nix
{ pkgs, ... }:
{
  ##########################################
  ## qView — simple, fast image viewer
  ##########################################
  home.packages = [
    pkgs.qview
  ];

  ##########################################
  ## Make qView my default image viewer
  ##########################################
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg"     = [ "qview.desktop" ];
      "image/png"      = [ "qview.desktop" ];
      "image/webp"     = [ "qview.desktop" ];
      "image/gif"      = [ "qview.desktop" ];
      "image/tiff"     = [ "qview.desktop" ];
      "image/bmp"      = [ "qview.desktop" ];
      "image/svg+xml"  = [ "qview.desktop" ];
      "image/*"        = [ "qview.desktop" ];
    };
  };

  # If I also manage ~/.config/mimeapps.list elsewhere, I keep only one owner.
  # (Your setup already uses xdg.mimeApps via HM, so this is fine.)
}


