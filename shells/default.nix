{ pkgs }:

{
  avalonia = import ./avalonia.nix { inherit pkgs; };
  blazor   = import ./blazor.nix   { inherit pkgs; };
}