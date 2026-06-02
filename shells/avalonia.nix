{ pkgs }:

let
  dotnet = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.sdk_8_0
    pkgs.dotnetCorePackages.sdk_10_0
  ];

  # X11/Avalonia runtime dependencies
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

    zlib
    icu
  ];

in

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    dotnet
    git
    pkg-config
  ];

  buildInputs = guiDeps;

  shellHook = ''
    export DOTNET_ROOT=${dotnet}
    export PATH=$DOTNET_ROOT/bin:$PATH

    # Runtime libraries for Avalonia / Skia / X11
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath guiDeps}:$LD_LIBRARY_PATH"

    # Better compatibility with native .NET libs
    export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=0

    echo "Avalonia UI dev shell ready"
    dotnet --version
  '';
}