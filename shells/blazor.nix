{ pkgs }:

let
  dotnet = pkgs.dotnet-sdk_9;
in

pkgs.mkShell {
  buildInputs = [
    dotnet
    pkgs.nodejs_20
    pkgs.git
    pkgs.openssl
    pkgs.pkg-config
    pkgs.icu
    pkgs.zlib
  ];

  shellHook = ''
    export DOTNET_ROOT=${dotnet}
    export PATH=$DOTNET_ROOT/bin:$PATH

    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
      pkgs.openssl
      pkgs.zlib
      pkgs.icu
    ]}

    echo "Blazor dev shell ready"
    dotnet --version
  '';
}