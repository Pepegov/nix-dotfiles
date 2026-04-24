{ config, pkgs, ... }:

let
  dotnet = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.sdk_8_0
    pkgs.dotnetCorePackages.sdk_9_0
    pkgs.dotnetCorePackages.sdk_10_0
  ];

  aspnet = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.aspnetcore_8_0
    pkgs.dotnetCorePackages.aspnetcore_9_0
    pkgs.dotnetCorePackages.aspnetcore_10_0
  ];

  dotnet-runtime = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.runtime_8_0
    pkgs.dotnetCorePackages.runtime_9_0
    pkgs.dotnetCorePackages.runtime_10_0
  ];
in
{
  environment.systemPackages = with pkgs; [
    # ui
    mongodb-compass
    jetbrains.rider
    jetbrains.datagrip
    postman
    vscode
    code-cursor

    # .net
    #dotnet
    # aspnet
    # dotnet-runtime
    pkgs.dotnetCorePackages.sdk_8_0
    pkgs.dotnetCorePackages.sdk_9_0
    pkgs.dotnetCorePackages.sdk_10_0

    dotnetCorePackages.aspnetcore_8_0
    dotnetCorePackages.aspnetcore_9_0
    dotnetCorePackages.aspnetcore_10_0

    dotnetCorePackages.runtime_8_0
    dotnetCorePackages.runtime_9_0
    dotnetCorePackages.runtime_10_0

    dotnet-ef
    msbuild

    # python
    pipx
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.tkinter
    python3Packages.pyside6
    python3Packages.pyqt6
    python3Packages.pyqt5

    python313Packages.audioread
    python313Packages.configobj
    python313Packages.levenshtein
    python313Packages.lxml
    python313Packages.mutagen
    python313Packages.pyacoustid
    python313Packages.pyparsing
    python313Packages.pyqt5-sip
    python313Packages.rapidfuzz
    python313Packages.unidecode

    # front
    pnpm
    nodejs_24
    nodePackages.typescript

    # arduino
    arduino
    gnumake
    screen

    # rust
    cargo
    rustc

    # other
    gcc
    gccgo
    pkg-config
    openssl
    ffmpeg
    mage
    direnv
    go
    postgresql
  ];
}
