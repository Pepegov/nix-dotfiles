{ config, pkgs, lib, ... }:

{
  boot.initrd.kernelModules = [
      "tun"
  ];

  networking.firewall = {
    checkReversePath = "loose"; 
    trustedInterfaces = [ "tun0" "singbox_tun" "singbox_tun0" ]; 
  };
}