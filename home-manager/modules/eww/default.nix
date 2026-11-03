{ pkgs, ... }:

let
  launcher = pkgs.writeShellApplication {
    name = "eww-external-widgets";
    runtimeInputs = [ pkgs.eww pkgs.xorg.xrandr pkgs.coreutils ];
    text = builtins.readFile ./config/scripts/launch.sh;
  };
in
{
  home.packages = [ pkgs.eww pkgs.jq pkgs.curl ];

  xdg.configFile."eww/eww.yuck".source = ./config/eww.yuck;
  xdg.configFile."eww/eww.scss".source = ./config/eww.scss;
  xdg.configFile."eww/scripts/codex-limits.sh" = {
    source = ./config/scripts/codex-limits.sh;
    executable = true;
  };
  xdg.configFile."eww/scripts/exchange-rates.sh" = {
    source = ./config/scripts/exchange-rates.sh;
    executable = true;
  };
  systemd.user.services.eww-external-widgets = {
    Unit = {
      Description = "Persistent Eww widgets on the external monitor";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${launcher}/bin/eww-external-widgets";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
