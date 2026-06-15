{ config, pkgs, lib, ... }:

let
  baseConfig = builtins.readFile /home/pepegov/nix/hidden/work/work.ovpn;
  modifiedConfig = builtins.replaceStrings ["dev tun"] ["dev tun_work"] baseConfig;
  fullConfig = ''
    pull-filter ignore redirect-gateway
  '' + modifiedConfig;
  corpSubnets = [
    "10.8.0.0/24"
    "192.168.64.0/24"
    "192.168.66.0/24"
    "192.168.98.0/24"
    "192.168.108.0/24"
    "192.168.113.0/24"
    "192.168.117.0/24"
    "192.168.122.0/24"
    "192.168.123.0/24"
  ];
  transportIps = [
    "45.87.143.207"
    "188.234.180.75"
  ];
in
{
  environment.systemPackages = with pkgs; [ openvpn ];

  services.openvpn.servers.work = {
    config = fullConfig;
    updateResolvConf = true;
    autoStart = false;
  };

  systemd.services.openvpn-work = {
    postStart = lib.concatStringsSep "\n" (
      map (addr: "${pkgs.iproute2}/bin/ip rule add to ${addr} lookup main priority 90 2>/dev/null || true") transportIps
      ++ map (net: "${pkgs.iproute2}/bin/ip rule add to ${net} lookup main priority 91 2>/dev/null || true") corpSubnets
    );
    preStop = lib.concatStringsSep "\n" (
      map (addr: "${pkgs.iproute2}/bin/ip rule del to ${addr} lookup main priority 90 2>/dev/null || true") transportIps
      ++ map (net: "${pkgs.iproute2}/bin/ip rule del to ${net} lookup main priority 91 2>/dev/null || true") corpSubnets
    );
  };
}
