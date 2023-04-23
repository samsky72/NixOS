# My packages.
{ config, pkgs, ...}: {
home.packages = with pkgs; [
    citrix_workspace
    gcc
    john
    hashcat
    hashcat-utils
    nasm
    nmap
    nmapsi4
    nur.repos.xddxdd.svp
    rarcrack
    rnix-lsp
    sn0int
    testssl
    trivy
    qt5.full
    qtcreator
    zap
  ];
}

