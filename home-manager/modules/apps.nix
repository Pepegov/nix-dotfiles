{ config, pkgs, lib, ... }:

let
  mkApp = name: exec:
    let
      script = pkgs.writeShellScriptBin name ''
        ${exec}
      '';

      desktop = pkgs.makeDesktopItem {
        name = name;
        desktopName = name;
        exec = "${script}/bin/${name}";
        type = "Application";
      };
    in
    [
      script
      desktop
    ];

in
{
  home.packages = lib.flatten [
    (mkApp
      "U-Siem"
      ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __GLX_VENDOR_LIBRARY_NAME=nvidia

        exec wine \
          "${config.home.homeDirectory}/nix/hidden/work/U_SIEM/U_SIEM.exe"
      '')
  ];
}