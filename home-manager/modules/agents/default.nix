{ config, pkgs, lib, ... }:

let

in
{
  imports = [
    ./claude.nix
    ./codex.nix
    ./opencode.nix
  ];

  home.file.".agents/skills" = {
    source = ./config/common/skills;
    recursive = true;
  };
}
