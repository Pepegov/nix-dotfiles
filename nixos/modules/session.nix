{ config, pkgs, lib, ... }:

{
    services.xserver = {
        videoDrivers = [ "amdgpu" ];  
        
        # Enable the X11 windowing system.
        enable = true;

        # Configure keymap in X11
        xkb = {
            layout = "us";
            variant = "";
        };

        # Configure bspwm
        windowManager.bspwm.enable = true;
        # Slick greeter rejects NixOS session names such as `none+bspwm` and
        # falls back to another desktop.  The GTK greeter uses LightDM's
        # session hint directly, so it honors `defaultSession` below.
        displayManager.lightdm = {
            enable = true;
            background = ../../home-manager/modules/wallpaper/assets/background_lightdm.png;

            greeters = {
                slick.enable = false;
                gtk = {
                    enable = true;
                    theme = {
                        package = pkgs.gnome-themes-extra;
                        name = "Adwaita-dark";
                    };
                    iconTheme = {
                        package = pkgs.adwaita-icon-theme;
                        name = "Adwaita";
                    };
                    cursorTheme = {
                        package = pkgs.adwaita-icon-theme;
                        name = "Adwaita";
                        size = 24;
                    };
                    extraConfig = ''
                        user-background = false
                        transition-type = none
                    '';
                };
            };
        };
    };

    # Budgie environment
    services.desktopManager.budgie.enable = true;

    # Run after PRIME has connected the output providers and enabled displays.
    # Output names differ between NVIDIA modes, so identify the laptop panel
    # by its stable eDP prefix instead of a driver-specific full name.
    services.xserver.displayManager.setupCommands = lib.mkAfter ''
        internal_display=$(${pkgs.xrandr}/bin/xrandr --query | ${pkgs.gawk}/bin/awk '/ connected/ && $1 ~ /^eDP/ { print $1; exit }')
        external_display=$(${pkgs.xrandr}/bin/xrandr --query | ${pkgs.gawk}/bin/awk '/ connected/ && $1 !~ /^eDP/ { print $1; exit }')

        if [ -n "$external_display" ] && [ -n "$internal_display" ]; then
            ${pkgs.xrandr}/bin/xrandr --output "$external_display" --auto
            ${pkgs.xrandr}/bin/xrandr --output "$internal_display" --auto --right-of "$external_display" --primary
        elif [ -n "$internal_display" ]; then
            ${pkgs.xrandr}/bin/xrandr --output "$internal_display" --auto --primary
        elif [ -n "$external_display" ]; then
            ${pkgs.xrandr}/bin/xrandr --output "$external_display" --auto --primary
        fi
    '';

    services.displayManager.defaultSession = "none+bspwm";

    # environment.sessionVariables = {
    #     LIBVA_DRIVER_NAME = "radeonsi";
    #     MOZ_DISABLE_RDD_SANDBOX = "1";
    #     MOZ_X11_EGL = "1";
    # };

    environment.loginShellInit = ''
        # Встроенный экран (eDP*)
        export DISPLAY_INTERNAL=$(xrandr --query | awk '/ connected/ && $1 ~ /^eDP/ { print $1; exit }')

        # Первый внешний экран (DP-*, HDMI-*, и т.д., но не eDP)
        export DISPLAY_EXTERNAL=$(xrandr --query | awk '/ connected/ && $1 !~ /^eDP/ { print $1; exit }')
    '';

    environment.systemPackages = with pkgs; [
        bspwm
        sxhkd
        polybar
        picom
        rofi
        brightnessctl
    ];
}
