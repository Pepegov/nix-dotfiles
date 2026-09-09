{ pkgs, pkgs-unstable }:

{
  dotnet = import ./dotnet.nix { inherit pkgs pkgs-unstable; };
}
