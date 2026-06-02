{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ntfs3g
    parted
    gparted
  ];


  # fileSystems."/run/media/pepegov/Windows" = {
  #   device = "/dev/disk/by-uuid/121E7D6F0B963D40";
  #   fsType = "ntfs-3g";

  #   options = [
  #     "rw"
  #     "uid=1000"
  #     "gid=100"
  #     "umask=022"
  #     "windows_names"
  #     "x-gvfs-show"
  #   ];
  # };

  systemd.tmpfiles.rules = [
    "d /run/media/Windows 0755 pepegov users -"
    "d /run/media/SecondData/libvirt/images 0755 root root -"
  ];

  fileSystems."/run/media/SecondData" = {
    device = "/dev/disk/by-uuid/4ad95162-a99f-420c-9004-84357c40f058";
    fsType = "ext4";
    options = [ "defaults" "noatime" ];
  };
}
