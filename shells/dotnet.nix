{ pkgs, pkgs-unstable, ... }:

let
  dotnet = pkgs-unstable.dotnetCorePackages.combinePackages [
    pkgs-unstable.dotnetCorePackages.sdk_8_0
    pkgs-unstable.dotnetCorePackages.sdk_9_0
    pkgs-unstable.dotnetCorePackages.sdk_10_0

    pkgs-unstable.dotnetCorePackages.aspnetcore_9_0
    pkgs-unstable.dotnetCorePackages.runtime_9_0
    pkgs-unstable.dotnetCorePackages.aspnetcore_10_0
    pkgs-unstable.dotnetCorePackages.runtime_10_0
  ];

  guiDeps = with pkgs; [
    fontconfig
    freetype
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXrandr
    xorg.libXi
    xorg.libXcursor
    xorg.libXfixes
    xorg.libICE
    xorg.libSM
    mesa
    libGL
    wayland
  ];

  runtimeDeps = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
    icu
    libuuid
    krb5
    libkrb5
    libunwind
  ];

  libraryDeps = guiDeps ++ runtimeDeps;
in

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    dotnet
    bashInteractive
    pkgs-unstable.bun
    pkgs-unstable.nodejs
    git
    pkg-config
    nix-ld
  ];

  buildInputs = libraryDeps;

  shellHook = ''
    export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    export SSL_CERT_DIR=/etc/ssl/certs

    export DOTNET_ROOT=${dotnet}
    export PATH=$DOTNET_ROOT/bin:$PATH
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath libraryDeps}:$LD_LIBRARY_PATH"

    export NIX_LD=${pkgs.stdenv.cc.bintools.dynamicLinker}
    export NIX_LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath runtimeDeps}

    export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=0
    export DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=0
    export ASPNETCORE_Kestrel__Certificates__Default__Path=~/.config/certificate/localhost.pfx
    export ASPNETCORE_Kestrel__Certificates__Default__Password=

    echo "Dotnet dev shell ready"
    dotnet --version
  '';
}
