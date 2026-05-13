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
in

pkgs.mkShell {
  # основные пакеты
  nativeBuildInputs = [
    dotnet
    pkgs.bun
    pkgs.git
    pkgs.pkg-config
  ] ++ guiDeps;

  # если нужно компилировать нативные зависимости
  buildInputs = guiDeps;

  # переменные для dotnet
  shellHook = ''
    export DOTNET_ROOT=${dotnet}
    export PATH=$DOTNET_ROOT/bin:$PATH

    # Avalonia требует графических библиотек в LD_LIBRARY_PATH
    export LD_LIBRARY_PATH="$(printf "%s:" ${pkgs.lib.makeLibraryPath skiaDeps})$LD_LIBRARY_PATH"

    echo "Work dev shell ready"
    dotnet --version
  '';
}