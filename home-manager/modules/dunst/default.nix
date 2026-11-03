{ pkgs, ... }:

let
  htmlNotificationFormatter = pkgs.writeShellApplication {
    name = "dunst-html-notification-formatter";
    runtimeInputs = [ pkgs.dunst pkgs.libnotify pkgs.python3 ];
    text = ''
      exec python3 ${./config/format-html-notification.py}
    '';
  };
in
{
  # BSPWM does not otherwise start a notification daemon.
  services.dunst = {
    enable = true;

    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        origin = "top-right";
        offset = "24x48";
        width = 380;
        height = 180;
        notification_limit = 5;

        font = "JetBrainsMono Nerd Font 11";
        markup = "full";
        always_run_script = true;
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        ellipsize = "middle";
        show_age_threshold = 60;

        padding = 14;
        horizontal_padding = 14;
        text_icon_padding = 12;
        gap_size = 10;
        frame_width = 1;
        separator_height = 1;
        corner_radius = 14;
        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 48;

        progress_bar = true;
        progress_bar_height = 8;
        progress_bar_frame_width = 0;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;

        background = "#17271C";
        foreground = "#E4D1A6";
        frame_color = "#5C4939";
        separator_color = "frame";
        highlight = "#D2B77C";
      };

      urgency_low = {
        background = "#17271C";
        foreground = "#A99A7C";
        frame_color = "#5C4939";
        highlight = "#B29570";
        timeout = 5;
      };

      urgency_normal = {
        background = "#203828";
        foreground = "#E4D1A6";
        frame_color = "#D2B77C";
        highlight = "#8EA06B";
        timeout = 8;
      };

      urgency_critical = {
        background = "#203828";
        foreground = "#F0E6D2";
        frame_color = "#C17C5D";
        highlight = "#C17C5D";
        timeout = 0;
      };

      KDEConnectHtml = {
        appname = "KDE Connect";
        format = "";
        script = "${htmlNotificationFormatter}/bin/dunst-html-notification-formatter";
      };
    };
  };
}
