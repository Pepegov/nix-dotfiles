{ config, pkgs, pkgs-unstable, lib, ... }:

{
  environment.systemPackages = [ pkgs-unstable.throne ];

  security.wrappers.ThroneCore = {
    source = "${pkgs-unstable.throne}/share/throne/ThroneCore";
    owner = "root";
    group = "root";
    # Taken from https://github.com/SagerNet/sing-box/blob/dev-next/release/config/sing-box.service
    capabilities = "cap_net_admin,cap_net_raw,cap_net_bind_service,cap_sys_ptrace,cap_dac_read_search+ep";
  };

  # avoid resolvectl password prompt popping up three times
  # https://github.com/SagerNet/sing-tun/blob/0686f8c4f210f4e7039c352d42d762252f9d9cf5/tun_linux.go#L1062
  security.polkit.extraConfig = lib.mkIf config.services.resolved.enable ''
    polkit.addRule(function(action, subject) {
      const allowedActionIds = [
        "org.freedesktop.resolve1.revert",
        "org.freedesktop.resolve1.set-domains",
        "org.freedesktop.resolve1.set-default-route",
        "org.freedesktop.resolve1.set-dns-servers"
      ];

      if (allowedActionIds.indexOf(action.id) !== -1) {
        try {
          var parentPid = polkit.spawn(["${lib.getExe' pkgs.procps "ps"}", "-o", "ppid=", subject.pid]).trim();
          var parentCap = polkit.spawn(["${lib.getExe' pkgs.libcap "getpcaps"}", parentPid]).trim();
          if (parentCap.includes("cap_net_admin") && parentCap.includes("cap_net_raw")) {
            return polkit.Result.YES;
          } else {
            return polkit.Result.NOT_HANDLED;
          }
        } catch (e) {
          return polkit.Result.NOT_HANDLED;
        }
      }
    })
  '';
}