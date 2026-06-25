{ config, pkgs, lib, ... }:

let
  baseConfig = builtins.readFile /home/pepegov/nix/hidden/work/work.ovpn;
  modifiedConfig = builtins.replaceStrings ["dev tun"] ["dev tun_work"] baseConfig;
  fullConfig = ''
    pull-filter ignore redirect-gateway
  '' + modifiedConfig;

  baseInfraConfig = builtins.readFile /home/pepegov/nix/hidden/work/work-infra.ovpn;
  modifiedInfraConfig = builtins.replaceStrings ["dev tun"] ["dev tun_work_infra"] baseInfraConfig;
  fullInfraConfig = ''
    pull-filter ignore redirect-gateway
  '' + modifiedInfraConfig;
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

  networking.extraHosts = ''
    # Work (infra VPN)
    10.0.31.40  gitlab-runner
    10.0.31.37  management-center
    10.0.31.38  resources
    10.0.31.31  linux-agents
    10.0.31.54  windows-agents
    10.0.31.30  gitlab.lab

    # Work (main VPN)
    192.168.117.1 gitlab.umbrella.moscow
    192.168.64.249 taiga.umbrella.moscow
    192.168.250.2  api.agent.local
    192.168.250.2  web.agent.local
    192.168.250.2  auth.agent.local
  '';

  services.openvpn.servers.work = {
    config = fullConfig;
    updateResolvConf = true;
    autoStart = false;
  };

  services.openvpn.servers.work-infra = {
    config = fullInfraConfig;
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

  systemd.services.openvpn-work-infra = {
    postStart = "${pkgs.iproute2}/bin/ip rule add to 10.0.31.0/24 lookup main priority 92 2>/dev/null || true";
    preStop = "${pkgs.iproute2}/bin/ip rule del to 10.0.31.0/24 lookup main priority 92 2>/dev/null || true";
  };
}
