{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ntfs3g
    parted
    gparted
  ];


  fileSystems."/run/media/pepegov/SecondData" = {
    device = "/dev/disk/by-uuid/121E7D6F0B963D40";
    fsType = "ntfs-3g";

    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "umask=022"
      "windows_names"
      "x-gvfs-show"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /run/media/pepegov/SecondData 0755 pepegov users -"
  ];
}