{ config, pkgs, lib, ... }:

let

in
{
  imports = [
    ./codex.nix
    ./opencode.nix
  ];

  home.file.".agents/skills" = {
    source = ./config/common/skills;
    recursive = true;
  };
}
