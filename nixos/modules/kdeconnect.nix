{ config, pkgs, lib, ... }:

{
    programs.kdeconnect.enable = true;

networking.firewall.allowedTCPPortRanges = [
  { from = 1714; to = 1764; }
];

networking.firewall.allowedUDPPortRanges = [
  { from = 1714; to = 1764; }
];

    environment.systemPackages = with pkgs; [
        zenity
	qt6.qttools
    ];
}
