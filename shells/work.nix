{ pkgs }:

let
  dotnet = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.sdk_9_0
    pkgs.dotnetCorePackages.sdk_10_0
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
  ];

  skiaDeps = with pkgs; [
    libGL
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    fontconfig
  ];

  aspireDeps = with pkgs; [
    stdenv.cc.cc
    glibc
    zlib
    openssl
    icu
    libuuid
    krb5
    libkrb5
    libunwind
  ];
in

pkgs.mkShell {
  # основные пакеты
  nativeBuildInputs = [
    dotnet
    pkgs.bashInteractive
    pkgs.bun
    pkgs.git
    pkgs.pkg-config
    pkgs.nix-ld
  ] ++ guiDeps;

  packages = [
    pkgs.bashInteractive
  ];

  # если нужно компилировать нативные зависимости
  buildInputs = guiDeps ++ aspireDeps;

  # переменные для dotnet
  shellHook = ''
    export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    export SSL_CERT_DIR=/etc/ssl/certs
    
    export DOTNET_ROOT=${dotnet}
    export PATH=$DOTNET_ROOT/bin:$PATH

    # Avalonia требует графических библиотек в LD_LIBRARY_PATH
    export LD_LIBRARY_PATH="$(printf "%s:" ${pkgs.lib.makeLibraryPath skiaDeps})$LD_LIBRARY_PATH"

    export NIX_LD=${pkgs.stdenv.cc.bintools.dynamicLinker}
    export NIX_LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath aspireDeps}

    export DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=0

    echo "Work dev shell ready"
    dotnet --version
  '';
}