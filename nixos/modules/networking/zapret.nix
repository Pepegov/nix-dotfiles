{ config, pkgs, lib, ... }:

{
  services.zapret = {
    enable = true;

    params = [
      # Основные параметры обхода
      "--dpi-desync=fake,disorder2"
      "--dpi-desync-autottl=2"
      "--dpi-desync-ttl=1"
      "--dpi-desync-fooling=badseq,md5sig"
      
      # Специфичные для UDP OpenVPN
      "--dpi-desync-split-pos=2"
      "--dpi-desync-split-pos=3"
      "--dpi-desync-repeats=2"
      
      # Для UDP важно указывать порты
      "--dpi-desync-udp-skip=0"  # Не пропускать UDP
      "--dpi-desync-udp-thresh=0" # Обрабатывать все UDP
    ];

    whitelist = [
      "vpn.umbrella.moscow" # WORK
      "ugrvpn.umbrella.moscow"  # WORK
      "youtube.com"
      "googlevideo.com"
      "ytimg.com"
      "youtu.be"
      "github.com"
      "telegram.org"
      "t.me"
      "telegram.me"
      "telegra.ph"
      "core.telegram.org"
      "userapi.telegram.org"
      "venus.web.telegram.org"
      "pluto.web.telegram.org"
      "aurora.web.telegram.org"
      "kademlia.web.telegram.org"
    ];

    udpPorts = [ "1199" "11000" "443" "53" ];

    httpSupport = true;
    udpSupport = true;
    configureFirewall = true;
  };

  # Отключаем автостарт zapret, чтобы контролировать вручную
  systemd.services.zapret.wantedBy = lib.mkForce [];
}