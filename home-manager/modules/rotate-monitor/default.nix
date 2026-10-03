{ ... }:

{
  xdg.configFile."bspwm/rotate-monitor.sh" = {
    source = ./config/rotate-monitor.sh;
    executable = true;
  };
}
