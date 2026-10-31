{ pkgs-unstable, ... }:

let
  dotnetPkgs = pkgs-unstable;

  dotnet = dotnetPkgs.dotnetCorePackages.combinePackages [
    dotnetPkgs.dotnetCorePackages.sdk_8_0
    dotnetPkgs.dotnetCorePackages.sdk_9_0
    dotnetPkgs.dotnetCorePackages.sdk_10_0

    dotnetPkgs.dotnetCorePackages.aspnetcore_9_0
    dotnetPkgs.dotnetCorePackages.runtime_9_0
    dotnetPkgs.dotnetCorePackages.aspnetcore_10_0
    dotnetPkgs.dotnetCorePackages.runtime_10_0
  ];

  # Keep every native library on the same nixpkgs revision as .NET. The SDK
  # itself resolves glibc through its RUNPATH, so glibc must not be added to
  # LD_LIBRARY_PATH: doing so breaks already-running programs such as Rider.
  riderGuiDeps = with dotnetPkgs; [
    fontconfig
    freetype
    libx11
    libxext
    libxrender
    libxrandr
    libxi
    libxcursor
    libxfixes
    libice
    libsm
    mesa
    libGL
    wayland
  ];

  runtimeDeps = with dotnetPkgs; [
    stdenv.cc.cc
    zlib
    openssl
    icu
    libuuid
    krb5
    libkrb5
    libunwind
  ];

  libraryDeps = riderGuiDeps ++ runtimeDeps;
in

dotnetPkgs.mkShell {
  nativeBuildInputs = with dotnetPkgs; [
    dotnet
    dotnetPkgs."dotnet-ef"
    bashInteractive
    bun
    nodejs
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
    # Do not inherit LD_LIBRARY_PATH: it can contain a glibc from another
    # nixpkgs revision and override the glibc required by libcoreclr.so.
    export LD_LIBRARY_PATH="${dotnetPkgs.lib.makeLibraryPath libraryDeps}"

    export NIX_LD=${dotnetPkgs.stdenv.cc.bintools.dynamicLinker}
    export NIX_LD_LIBRARY_PATH=${dotnetPkgs.lib.makeLibraryPath runtimeDeps}

    export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=0
    export DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=0
    export ASPNETCORE_Kestrel__Certificates__Default__Path=~/.config/certificate/localhost.pfx
    export ASPNETCORE_Kestrel__Certificates__Default__Password=

    echo "Dotnet dev shell ready"
    dotnet --version
  '';
}
