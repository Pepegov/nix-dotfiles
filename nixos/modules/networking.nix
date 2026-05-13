{ config, pkgs, lib, ... }:

{
  boot.initrd.kernelModules = [
      "tun"
  ];
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv4.conf.default.forwarding" = true;

    # Отключаем rp_filter — критично для TUN
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv4.conf.default.rp_filter" = 0;
    "net.ipv4.conf.singbox_tun.rp_filter" = 0;
  };

  environment.systemPackages = with pkgs; [
    v2rayn	
    v2ray-geoip          # для geoip.dat
    v2ray-domain-list-community  # для geosite.dat
    xray
    sing-box
    sshuttle
    wireguard-tools
    throne
    hysteria
    openvpn
  ];

  networking.hostName = "pepegov"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy
  #networking.proxy.default = "http://127.0.0.1:10808"; # For v2rayN
  #networking.proxy.noProxy = "127.0.0.1,localhost,pesni.fm,music.pesni.me,music.pesni.me,www.reddit.com,reddit.com,lkfl2.nalog.ru,nalog.ru,www.gosuslugi.ru,gosuslugi.ru,beeline.ru";

  # Enable networking
  networking.networkmanager.enable = true;

  #v2raya
  services.v2raya.enable = true;
  #services.v2raya.cliPackage = pkgs.xray;
  
  # V2rayN
  systemd.tmpfiles.rules = [
    # Создаём директорию bin, если её нет
    "d /home/pepegov/.local/share/v2rayN/bin 0755 pepegov users -"
    # Ссылка на исполняемый файл xray
    "L+ /home/pepegov/.local/share/v2rayN/bin/xray/xray - - - - ${pkgs.xray}/bin/xray"
    # Ссылки на геоданные из соответствующих пакетов
    "L+ /home/pepegov/.local/share/v2rayN/bin/geoip.dat - - - - ${pkgs.v2ray-geoip}/share/v2ray/geoip.dat"
    "L+ /home/pepegov/.local/share/v2rayN/bin/geosite.dat - - - - ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat"
    # sing-box
    "L+ /home/pepegov/.local/share/v2rayN/bin/sing_box/sing-box - - - - ${pkgs.sing-box}/bin/sing-box"
  ];
  services.resolved = {
    enable = true;
    fallbackDns = [ "1.1.1.1" "8.8.8.8" "2606:4700:4700::1111" ];
    extraConfig = ''
      DNSStubListener=yes
      Cache=yes
      Domains=~.
    '';
  };
  networking.firewall = {
    checkReversePath = "loose";  # решает многие проблемы с routing в TUN
    trustedInterfaces = [ "tun0" "singbox_tun" "singbox_tun0" ]; 
  };
  networking.firewall.extraCommands = lib.mkAfter ''
    # DNS запросы из localhost всегда в main таблицу
    iptables -t mangle -A OUTPUT -p udp --dport 53 -m owner --uid-owner 0 -j MARK --set-mark 1 2>/dev/null || true
    iptables -t mangle -A OUTPUT -p tcp --dport 53 -m owner --uid-owner 0 -j MARK --set-mark 1 2>/dev/null || true
    ip rule add fwmark 1 table main priority 500 2>/dev/null || true
  '';

  # OpenVPN
  services.openvpn.servers = {
    officeVPN = {
      config = builtins.readFile /home/pepegov/.vpn/ovpn/work/config.ovpn;
      updateResolvConf = true;
    };
  };
  systemd.services.openvpn-officeVPN.wantedBy = lib.mkForce [];

  # Russ fix
  networking.extraHosts = ''
    # JetBrains
    77.239.114.0 datalore.jetbrains.com
    77.239.114.0 plugins.jetbrains.com
    77.239.114.0 download.jetbrains.com
    77.239.114.0 api.jetbrains.ai
    77.239.114.0 account.jetbrains.com
  '';
}
