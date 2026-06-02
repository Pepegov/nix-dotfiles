{ config, pkgs, lib, ... }:

{
  imports =
  [
    # Modules
    ./openvpn.nix
    ./tun.nix
    ./v2rayn.nix
    ./v2raya.nix
    ./zapret.nix
  ];

  #TODO возможно это не нужно
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv4.conf.default.forwarding" = true;

    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.default.rp_filter" = 0;
    "net.ipv4.conf.singbox_tun.rp_filter" = 0;
  };

  environment.systemPackages = with pkgs; [
    xray
    sing-box
    sshuttle
    tcpdump
  ];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "pepegov"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.extraHosts = ''
    # Work
    192.168.117.1 gitlab.umbrella.moscow
    192.168.64.249 taiga.umbrella.moscow

    # JetBrains
    77.239.114.0 datalore.jetbrains.com
    77.239.114.0 plugins.jetbrains.com
    77.239.114.0 download.jetbrains.com
    77.239.114.0 api.jetbrains.ai
    77.239.114.0 account.jetbrains.com
  '';
}
