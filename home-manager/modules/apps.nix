{ config, pkgs, lib, ... }:

let
  mkApp = {
      name,
    desktopName ? name,
    exec,

    comment ? "Desktop application",
    icon ? "application-x-executable",
    categories ? [ "Utility" ],
  }:
    let
      script = pkgs.writeShellScriptBin name ''
        ${exec}
      '';

      desktop = pkgs.makeDesktopItem {
        name = name;
        desktopName = desktopName;
        comment = comment;

        exec = "${script}/bin/${name}";

        icon = icon;
        terminal = false;
        type = "Application";

        categories = categories;
      };
    in
    [
      script
      desktop
    ];

in
{
  home.packages = lib.flatten [
    (mkApp {
      name = "U-Siem";

      exec = ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __GLX_VENDOR_LIBRARY_NAME=nvidia

        exec wine \
          "${config.home.homeDirectory}/nix/hidden/work/U_SIEM/U_SIEM.exe"
      '';

      comment = "U-SIEM desktop application";
      icon = "winetricks";
    })
    (mkApp {
      name = "opencode-terminal";
      desktopName = "OpenCode Terminal";
      exec = "alacritty -e opencode";
      comment = "OpenCode Terminal application";
      icon = "Alacritty";
    })
  ];
}