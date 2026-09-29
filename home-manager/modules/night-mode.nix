{ pkgs, ... }:

{
  home.packages = [ pkgs.redshift ];

  xdg.configFile."night-mode.sh" = {
    source = ../config/scripts/night-mode.sh;
    executable = true;
  };

  systemd.user.services = {
    night-mode-on = {
      Unit.Description = "Enable the night display color temperature";
      Service = {
        Type = "oneshot";
        ExecStart = "%h/.config/night-mode.sh night";
      };
    };

    night-mode-off = {
      Unit.Description = "Restore the normal display color temperature";
      Service = {
        Type = "oneshot";
        ExecStart = "%h/.config/night-mode.sh day";
      };
    };

    night-mode-sync = {
      Unit.Description = "Apply the display color temperature for the current time";
      Service = {
        Type = "oneshot";
        ExecStart = "%h/.config/night-mode.sh sync";
      };
    };
  };

  systemd.user.timers = {
    night-mode-on = {
      Unit.Description = "Enable night display colors at 22:00";
      Timer = {
        OnCalendar = "*-*-* 22:00:00";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };

    night-mode-off = {
      Unit.Description = "Restore normal display colors at 08:00";
      Timer = {
        OnCalendar = "*-*-* 08:00:00";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
