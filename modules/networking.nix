{ config, pkgs, ... }:

{
  networking.hostName = "pepegov"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy
  networking.proxy.default = "http://127.0.0.1:10808"; # For v2rayN
  networking.proxy.noProxy = "127.0.0.1,localhost,pesni.fm,music.pesni.me,music.pesni.me,www.reddit.com,reddit.com,nextcloud.pepegov.ru,lkfl2.nalog.ru,nalog.ru,www.gosuslugi.ru,gosuslugi.ru,beeline.ru";

  # Enable networking
  networking.networkmanager.enable = true;

  services.v2raya.enable = true;
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
  ];
}
