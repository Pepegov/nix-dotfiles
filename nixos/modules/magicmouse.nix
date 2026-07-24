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
      # sleep 3
      modprobe -r hid_magicmouse || true
      # modprobe hid_magicmouse
    '';
  };
}