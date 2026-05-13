{ pkgs }:

{
  avalonia = import ./avalonia.nix { inherit pkgs; };
  blazor   = import ./blazor.nix   { inherit pkgs; };
  work     = import ./work.nix     { inherit pkgs; };
}