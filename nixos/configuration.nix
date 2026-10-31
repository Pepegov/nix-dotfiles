{ config, pkgs, pkgs-unstable, inputs, ... }:

{
  imports =
    [
      inputs.calendarflow.nixosModules.default

      ./hardware-configuration.nix
      
      # Modules
      ./modules/lock.nix
      ./modules/work.nix
      ./modules/networking/networking.nix
      ./modules/boot.nix
      ./modules/hardware.nix
      ./modules/session.nix
      ./modules/audio.nix
      ./modules/gpg.nix
      ./modules/virtualisation.nix
      ./modules/kdeconnect.nix
      ./modules/programming.nix
      ./modules/user.nix
      ./modules/mount.nix
      ./modules/magicmouse.nix
      ./modules/printing.nix
      ./modules/garbage-collector.nix
      ./modules/programs.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.common.default = "*";
  };

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  boot.extraModprobeConfig = ''
    options rtw89_pci disable_clkreq=y disable_aspm_l1=y disable_aspm_l1ss=y
  '';

  system.stateVersion = "26.05";
}
