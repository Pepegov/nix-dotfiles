{ config, lib, pkgs, ... }:

{
  systemd.user.services.openvpn-officeVPN = {
    Unit = {
      Description = "OpenVPN officeVPN";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = "${pkgs.openvpn}/bin/openvpn --config /home/pepegov/.vpn/ovpn/work/config.ovpn";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = lib.mkForce [ ];
    };
  };
}