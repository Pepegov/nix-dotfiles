{ config, pkgs, lib, ... }:

{
  services.zapret = {
    enable = true;

    params = [
      "--dpi-desync=fake,disorder2"
      "--dpi-desync-autottl=2"
      "--dpi-desync-ttl=1"
      "--dpi-desync-fooling=badseq,md5sig"
    ];

    whitelist = [
      "vpn.umbrella.moscow" #work
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

    # blacklist — всё кроме перечисленного (не рекомендуется)
    # blacklist = [ "example.com" ];

    # Дополнительно
    httpSupport = true;      # HTTP (80 порт), редко нужен
    udpSupport = false;      # QUIC и прочий UDP
    udpPorts = [ 11000 ];       #443 основной порт MTProto + QUIC
    configureFirewall = true; # автоматически добавляет правила в iptables
  };

  systemd.services.zapret.wantedBy = lib.mkForce [];
}