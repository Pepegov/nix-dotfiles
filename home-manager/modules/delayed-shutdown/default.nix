{ ... }:

{
  xdg.configFile."delayed-shutdown/delayed-shutdown.sh" = {
    source = ./config/delayed-shutdown.sh;
    executable = true;
  };

  xdg.configFile."delayed-shutdown/status.sh" = {
    source = ./config/status.sh;
    executable = true;
  };
}
