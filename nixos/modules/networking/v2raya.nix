{ config, pkgs, lib, ... }:

{
  services.v2raya.enable = true;
  # Чтобы сервис видел modprobe и networking tools
  systemd.services.v2raya.serviceConfig.Environment = [
    "PATH=/run/current-system/sw/bin:/run/wrappers/bin"
  ];

  # TPROXY modules
  boot.kernelModules = [ "xt_TPROXY" "xt_socket" "xt_mark" ];
  #services.v2raya.cliPackage = pkgs.xray;
}