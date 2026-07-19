{
    boot = {
        kernelParams = [
            "nvidia-drm.modeset=1"
            #"amdgpu.dcdebugmask=0x10" #Fix video fliping error
        ];

        initrd.kernelModules = [
            "amdgpu"
            "hid_magicmouse" #apple touchpad support
        ];

        loader = {
            systemd-boot.enable = false;
            
	    grub.configurationLimit = 5;
            grub.enable = true;
            grub.device = "nodev";
            grub.useOSProber = true;
            grub.efiSupport = true;
            
            efi.canTouchEfiVariables = true;
            efi.efiSysMountPoint = "/boot";
        };
    };
}
