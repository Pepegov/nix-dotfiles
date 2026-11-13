{ pkgs, ... }:

let
  night-mode = pkgs.writeShellApplication {
    name = "night-mode";
    runtimeInputs = [ pkgs.coreutils pkgs.gawk pkgs.gnused pkgs.picom pkgs.procps pkgs.redshift pkgs.systemd ];
    text = builtins.readFile ./config/night-mode.sh;
  };
in
{
  home.packages = [ pkgs.redshift ];

  xdg.configFile."night-mode.sh" = {
    source = "${night-mode}/bin/night-mode";
    executable = true;
  };

  xdg.configFile."night-mode/grayscale.glsl".source = ./config/grayscale.glsl;
  xdg.configFile."night-mode/color.glsl".source = ./config/color.glsl;

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

    night-mode-grayscale = {
      Unit.Description = "Enable grayscale display mode";
      Service = {
        Type = "oneshot";
        ExecStart = "%h/.config/night-mode.sh grayscale";
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

    night-mode-grayscale = {
      Unit.Description = "Enable grayscale display mode at 22:30";
      Timer = {
        OnCalendar = "*-*-* 22:30:00";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
