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
        # Rider ships its own patched .NET runtime. Do not let the dev shell's
        # loader and .NET variables override its bundled runtime or OpenSSL.
        exec nix develop ${config.home.homeDirectory}/nix#${shell} --command \
          env -u LD_LIBRARY_PATH -u NIX_LD -u NIX_LD_LIBRARY_PATH \
          -u DOTNET_ROOT -u DOTNET_ROOT_X64 -u DOTNET_HOST_PATH \
          rider "$@"
      '';
    in
    [ desktop script ];
in
{
  home.packages =
    mkRider "Dotnet" "dotnet";
    # ++ (mkRider "Razor" "razor");
}
