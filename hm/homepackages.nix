# My packages.
{ config, pkgs, ...}: {
home.packages = with pkgs; [
    aircrack-ng
    citrix_workspace
    gcc
    john
    hashcat
    hashcat-utils
    nasm
    nmap
    nmapsi4
    nur.repos.xddxdd.svp
    okteta
    rarcrack
    rnix-lsp
    sn0int
    testssl
    trivy
    qt5.full
    qtcreator
    whois
    zap
  ];
}

