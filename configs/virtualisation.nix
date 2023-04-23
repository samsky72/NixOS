# Virtualisations configurations.
{ config, ... }: {
  virtualisation.virtualbox.host = {
    enable = true;                          # Use Virtual Box.
    enableExtensionPack = true;             # Install Oracle extension pack.
  };
}
