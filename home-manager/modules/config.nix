{ config, pkgs, lib, ... }:

{
  home.file.".config/bspwm" = {
    source = ../config/bspwm;
    recursive = true;
  };

  home.file.".config/sxhkd" = {
    source = ../config/sxhkd;
    recursive = true;
  };

  home.file.".config/polybar" = {
    source = ../config/polybar;
    recursive = true;
  };

  home.file.".config/picom" = {
    source = ../config/picom;
    recursive = true;
  };

  home.file.".config/opencode" = {
    source = ../config/agents/opencode;
    recursive = true;
  };

  home.file.".codex" = {
    source = ../config/agents/codex;
    recursive = true;
  };

  home.file.".agents/skills" = {
    source = ../config/agents/common/skills;
    recursive = true;
  };

  xdg.configFile = {
    "alacritty/alacritty.toml" = {
      source = ../config/alacritty/alacritty.toml;
      force = true;
    };
    "rofi/config.rasi".source = ../config/rofi/config.rasi;
    "rofi/theme.rasi".source = ../config/rofi/theme.rasi;
    "bspwm/rotate-monitor.sh" = {
      source = ../config/scripts/rotate-monitor.sh;
      executable = true;
    };
    "startup.sh" = {
      source = ../config/scripts/startup.sh;
      executable = true;
    };
    "wallpaper-rotate.sh" = {
      source = ../config/scripts/wallpaper-rotate.sh;
      executable = true;
    };
  };

  xdg.configFile."environment.d/env.conf".source = "${config.home.homeDirectory}/nix/hidden/enviroment.conf";
}
