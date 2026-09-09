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
}