{ config, pkgs, lib, ... }:

{
  boot.initrd.kernelModules = [
      "tun"
  ];

  networking.firewall = {
    checkReversePath = "loose"; 
    trustedInterfaces = [ "tun0" "tun_work" "singbox_tun" "singbox_tun0" ]; 
  };
}