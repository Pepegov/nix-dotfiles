{ pkgs, config, ... }:

let
  mkRider = name: shell:
    let
      desktop = pkgs.makeDesktopItem {
        name = "rider-${shell}";
        desktopName = "Rider (${name})";
        exec = "${script}/bin/rider-${shell}";
        icon = "rider";
        type = "Application";
        categories = [ "Development" "IDE" ];
        startupWMClass = "jetbrains-rider";
      };

      script = pkgs.writeShellScriptBin "rider-${shell}" ''
        exec nix develop ${config.home.homeDirectory}/nix#${shell} --command rider "$@"
      '';
    in
    [ desktop script ];
in
{
  home.packages =
    (mkRider "Blazor" "blazor")
    ++ (mkRider "Avalonia" "avalonia")
    ++ (mkRider "Work" "work");
    # ++ (mkRider "Razor" "razor");
}