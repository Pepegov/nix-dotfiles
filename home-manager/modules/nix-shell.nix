{ pkgs, ... }:

let
  mkRider = name: shell: pkgs.makeDesktopItem {
    name = "rider-${shell}";
    desktopName = "Rider (${name})";
    exec = "nix develop /etc/nixos/flake#${shell} --command rider %u";
    icon = "jetbrains-rider";
    type = "Application";
    categories = [ "Development" "IDE" ];
    startupWMClass = "jetbrains-rider";
  };
in
{
  environment.systemPackages = with pkgs; [
    (mkRider "Blazor" "blazor")
  ];
}