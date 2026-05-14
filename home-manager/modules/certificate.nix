{ config, lib, pkgs, ... }:

let
  cfg = config.my.certificate;
in
{
  options.my.certificate = {
    enable = lib.mkEnableOption "Generate ASP.NET development certificate";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
    };

    path = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/certificate";
    };

    password = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "PFX password (empty is allowed for dev)";
    };
  };

  config = lib.mkIf cfg.enable {

    home.packages = [ pkgs.openssl ];

    home.activation.aspnetCertificate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      set -euo pipefail

      CERT_DIR="${cfg.path}"
      DOMAIN="${cfg.domain}"
      PASS="${cfg.password}"

      mkdir -p "$CERT_DIR"

      CA_KEY="$CERT_DIR/ca.key"
      CA_CRT="$CERT_DIR/ca.crt"

      KEY="$CERT_DIR/$DOMAIN.key"
      CSR="$CERT_DIR/$DOMAIN.csr"
      CRT="$CERT_DIR/$DOMAIN.crt"
      PFX="$CERT_DIR/$DOMAIN.pfx"

      # CA
      ${pkgs.openssl}/bin/openssl genpkey -algorithm RSA -out "$CA_KEY"

      ${pkgs.openssl}/bin/openssl req -x509 -new -nodes \
        -key "$CA_KEY" \
        -out "$CA_CRT" \
        -subj "/CN=dev-ca/O=dev-ca"

      # Server key
      ${pkgs.openssl}/bin/openssl genpkey -algorithm RSA -out "$KEY"

      ${pkgs.openssl}/bin/openssl req -new \
        -key "$KEY" \
        -out "$CSR" \
        -subj "/CN=$DOMAIN/O=dev"

      cat > "$CERT_DIR/ext.cnf" <<EOF
        basicConstraints = CA:FALSE
        subjectAltName = DNS:$DOMAIN
        EOF

      # Cert
      ${pkgs.openssl}/bin/openssl x509 -req \
        -in "$CSR" \
        -CA "$CA_CRT" \
        -CAkey "$CA_KEY" \
        -CAcreateserial \
        -out "$CRT" \
        -days 365 \
        -extfile "$CERT_DIR/ext.cnf"

      # PFX (what ASP.NET needs)
      ${pkgs.openssl}/bin/openssl pkcs12 -export \
        -out "$PFX" \
        -inkey "$KEY" \
        -in "$CRT" \
        -passout pass:"$PASS"

      rm -f "$CERT_DIR/ext.cnf" "$CSR"

      echo "ASP.NET cert generated at $PFX"
    '';
  };
}