{ config, pkgs, lib, ... }:

{
  xdg.configFile = {
    "bspwm" = {
      source = ./config/bspwm;
      recursive = true;
    };

    "sxhkd" = {
      source = ./config/sxhkd;
      recursive = true;
    }

    "polybar" = {
      source = ./config/polybar;
      recursive = true;
    };

    "startup.sh" = {
      source = ./config/startup.sh;     
      executable = true;
    };
}