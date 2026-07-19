{ config, pkgs, ... }:

{
  boot.initrd.kernelModules = [
      "hid_magicmouse" 
  ];
  
  systemd.services.restart-hid-magicmouse = {
    description = "Restart hid_magicmouse";

    wantedBy = [ "graphical.target" ];
    after = [ "graphical.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };

    path = with pkgs; [
      kmod
    ];

    script = ''
      modprobe -r hid_magicmouse
    '';
  };
}