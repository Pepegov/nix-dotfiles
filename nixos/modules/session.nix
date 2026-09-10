{ config, pkgs, ... }:

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

        # Budgie envinroment
        desktopManager.budgie.enable = true;
        # Configure bspwm
        windowManager.bspwm.enable = true;
        # LightDM is also used by light-locker for the lock screen.
        displayManager.lightdm = {
            enable = true;
            background = ../../home-manager/images/background_lightdm.png;
            extraSeatDefaults = "user-session=none+bspwm";

            greeters = {
                # Budgie enables Slick by default, so configure that greeter
                # instead of competing with it for the LightDM session.
                gtk.enable = false;
                slick = {
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
                    };
                    font = {
                        package = pkgs.noto-fonts;
                        name = "Noto Sans 11";
                    };
                };
            };
        };
    };
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
