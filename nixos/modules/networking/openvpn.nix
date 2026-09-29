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
    192.168.254.40  gitlab-runner
    192.168.254.37  management-center
    192.168.254.38  resources
    192.168.254.31  linux-agents
    192.168.254.54  windows-agents
    192.168.254.30  gitlab.lab

    # 192.168.254.38  resources.umbr.infra
    # 192.168.254.38  files.umbr.infra
    # 192.168.254.38  db-adminer.umbr.infra
    # 192.168.254.38  management-center-auth.umbr.infra
    # 192.168.254.37  management-center.umbr.infra
    # 192.168.254.37  management-center-test.umbr.infra
    # 192.168.254.37  management-center-test-api.umbr.infra
    # 192.168.254.37  management-center-stable.umbr.infra
    # 192.168.254.37  management-center-stable-api.umbr.infra

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
    postStart = ''
      ${pkgs.iproute2}/bin/ip rule add to 192.168.254.0/24 lookup main priority 92 2>/dev/null || true
      ${pkgs.systemd}/bin/resolvectl dns tun_work_infra 192.168.254.100 || true
      ${pkgs.systemd}/bin/resolvectl domain tun_work_infra '~umbr.infra' || true
    '';
    preStop = ''
      ${pkgs.iproute2}/bin/ip rule del to 192.168.254.0/24 lookup main priority 92 2>/dev/null || true
      ${pkgs.systemd}/bin/resolvectl revert tun_work_infra || true
    '';
  };
}
