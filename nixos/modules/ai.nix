{ pkgs, ... }:

{
  # ======================== OLLAMA ========================

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;

    host = "127.0.0.1";
    port = 11434;

    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "65536";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "1";

      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };
  };

  environment.systemPackages = with pkgs; [
    xdotool
    scrot
    wmctrl
    xdg-utils
    python3
  ];

  # ======================== FREELLMAPI ========================

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
