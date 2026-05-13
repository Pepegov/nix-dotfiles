
{
  services.zapret = {
    enable = true;

    params = [
      "--dpi-desync=fake,disorder2"  
      "--dpi-desync-ttl=1"
      "--dpi-desync-autottl=2"
    ];

    whitelist = [
      "youtube.com"
      "googlevideo.com"
      "ytimg.com"
      "youtu.be"
      "github.com"
    ];

    # blacklist — всё кроме перечисленного (не рекомендуется)
    # blacklist = [ "example.com" ];

    # Дополнительно
    httpSupport = true;      # HTTP (80 порт), редко нужен
    udpSupport = false;      # QUIC и прочий UDP
    configureFirewall = true; # автоматически добавляет правила в iptables
  };
}