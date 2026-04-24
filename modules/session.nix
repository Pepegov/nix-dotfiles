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
        # Configure lightdm
        displayManager.lightdm.enable = true;
        #displayManager.lightdm.greeters.gtk.enable = true;
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