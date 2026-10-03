{
    boot = {
        kernelParams = [
            "nvidia-drm.modeset=1"
            #"amdgpu.dcdebugmask=0x10" #Fix video fliping error
        ];

        initrd.kernelModules = [
            "amdgpu"
        ];

        loader = {
            systemd-boot.enable = false;
            
            grub.configurationLimit = 5;
            grub.enable = true;
            grub.device = "nodev";
            grub.useOSProber = true;
            grub.efiSupport = true;
            grub.splashImage = ../../home-manager/modules/wallpaper/assets/background_grub.png;
            grub.backgroundColor = "#0D0C07";
            grub.gfxmodeEfi = "auto";
            grub.gfxpayloadEfi = "keep";
            grub.extraConfig = ''
                set color_normal=white/black
                set color_highlight=black/brown
                set menu_color_normal=white/black
                set menu_color_highlight=black/brown
            '';
            
            efi.canTouchEfiVariables = true;
            efi.efiSysMountPoint = "/boot";
        };
    };
}
