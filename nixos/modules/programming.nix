{ config, pkgs, pkgs-unstable, inputs, ... }:

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

  # Rider launches .NET applications as child processes. Avalonia's native
  # SkiaSharp library does not have a RUNPATH, so it needs these libraries in
  # the inherited loader path. Keep glibc out of this list: Rider uses its own
  # runtime and an injected glibc can break it.
  riderGuiDeps = with pkgs; [
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

  rider = pkgs.jetbrains.rider.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      substituteInPlace "$out/rider/bin/rider" \
        --replace-fail 'export JDK_HOME=' \
        'LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath riderGuiDeps}:$LD_LIBRARY_PATH
         export LD_LIBRARY_PATH
         export JDK_HOME='
    '';
  });

in
{
  # Locally built Avalonia applications have no Nix RUNPATH for SkiaSharp.
  # Make the native GUI libraries available to applications launched from the
  # desktop session as well as from terminals and IDEs.
  environment.sessionVariables.LD_LIBRARY_PATH =
    pkgs.lib.makeLibraryPath riderGuiDeps;

  environment.systemPackages = with pkgs; [
    # ui
    mongodb-compass
    rider
    jetbrains.datagrip
    postman
    vscode
  
    # Ai tools
    pkgs-unstable.code-cursor
    pkgs-unstable.opencode
    inputs.openspec.packages.${pkgs.system}.default
    lmstudio

    # .net
    #dotnet
    #aspnet
    #dotnet-runtime
    dotnetCorePackages.sdk_8_0
    dotnetCorePackages.sdk_9_0
    dotnetCorePackages.sdk_10_0

    dotnetCorePackages.aspnetcore_8_0
    dotnetCorePackages.aspnetcore_9_0
    dotnetCorePackages.aspnetcore_10_0

    dotnetCorePackages.runtime_8_0
    dotnetCorePackages.runtime_9_0
    dotnetCorePackages.runtime_10_0

    avalonia
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
    bun

    # arduino
    arduino
    gnumake
    screen
    fritzing

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
    p11-kit
    gcr
    
    postgresql
    mariadb
  ];

  services.postgresql.enable = false;
  services.mysql.enable = false;

  security.pki.certificates = [
    (builtins.readFile /home/pepegov/nix/hidden/local_ca.crt)
  ];

  # fix CVE: CVE-2026-111943
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
  ];
}
