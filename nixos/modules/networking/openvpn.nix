{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    openvpn
  ];

  networking.resolvconf.enable = true;
  services.openvpn.servers = {
    officeVPN = {
      config = builtins.readFile /home/pepegov/.vpn/ovpn/work/config.ovpn;
      updateResolvConf = true;
    };
  };
  systemd.services.openvpn-officeVPN.wantedBy = lib.mkForce [];
}