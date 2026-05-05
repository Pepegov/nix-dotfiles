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

  xdg.configFile = {
    "startup.sh" = {
      source = ../config/startup.sh;     
      executable = true;
    };
  };
}