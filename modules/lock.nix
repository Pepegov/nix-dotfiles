{ config, pkgs, ... }:

{
  security.pam.services.lightdm = {};
  security.pam.services.light-locker = {};

  # Устанавливаем пакеты
  environment.systemPackages = with pkgs; [
    lightlocker
  ];

  # Настройка реакции на крышку
  services.logind.settings.Login = {
    HandleLidSwitch = "lock";
    HandleLidSwitchExternalPower = "lock";
  };

  # Автоблокировка через X idle
  services.xserver.displayManager.sessionCommands = ''
    # Таймер 10 минут (600 сек)
    xset s 600 600
    xset dpms 600 600 600

    # Запуск light-locker
    ${pkgs.lightlocker}/bin/light-locker \
      --lock-after-screensaver=0 \
      --lock-on-suspend \
      --lock-on-lid \
      --idle-hint \
      --late-locking &
  '';
}