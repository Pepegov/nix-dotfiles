{ config, pkgs, pkgs-unstable, ... }:

{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
    ];
    allowFrom = [ "localhost" ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Поддержка сканеров
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      sane-airscan
    ];
  };

  # Для USB-сканеров с поддержкой IPP-over-USB
  services.ipp-usb.enable = true;

  # Приложение для сканирования
  environment.systemPackages = with pkgs; [
    simple-scan
    sane-frontends
  ];
}