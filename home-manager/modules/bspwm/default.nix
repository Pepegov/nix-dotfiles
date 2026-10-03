{ ... }:

{
  home.file.".config/bspwm" = {
    source = ./config/bspwm;
    recursive = true;
  };

  home.file.".config/sxhkd" = {
    source = ./config/sxhkd;
    recursive = true;
  };

  xdg.configFile."startup.sh" = {
    source = ./config/startup.sh;
    executable = true;
  };
}
