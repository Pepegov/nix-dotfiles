{ pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers.freellmapi = {
      image = "ghcr.io/tashfeenahmed/freellmapi:v0.16.17";
      ports = [ "127.0.0.1:3001:3001" ];
      volumes = [ "freellmapi-data:/app/server/data" ];
      environment = {
        NODE_ENV = "production";
        PORT = "3001";
      };
      extraOptions = [ "--env-file=/var/lib/freellmapi/environment" ];
    };
  };

  systemd.services.docker-freellmapi.preStart = ''
    ${pkgs.coreutils}/bin/install -d -m 0700 /var/lib/freellmapi
    if [ ! -s /var/lib/freellmapi/environment ]; then
      umask 077
      ${pkgs.openssl}/bin/openssl rand -hex 32 | ${pkgs.gnused}/bin/sed 's/^/ENCRYPTION_KEY=/' > /var/lib/freellmapi/environment
    fi
  '';
}
