{ config, pkgs, lib, ... }:

{
    # Kernel
    boot.kernelPackages = pkgs.linuxPackages_6_6;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    # Firmware support
    hardware.enableRedistributableFirmware = true;

    #Enable OpenGL
    hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
            libva
            libva-utils
            libva-vdpau-driver
            nvidia-vaapi-driver
            mesa
        ];
    };

    specialisation = {
        nvidia-offload.configuration = {
            services.xserver.deviceSection = ''
                Option "DRI" "2"
            '';

            boot.kernelParams = [
                "amdgpu.dcdebugmask=0x10"
                "nvidia.NVreg_DynamicPowerManagement=0x02"
                "pcie_aspm=force"
            ];
            boot.initrd.kernelModules = [
                "tun"
                "amdgpu"
                "nvidia"
                "nvidia_modeset"
                "nvidia_drm"
            ];

            system.nixos.tags = [ "nvidia-offload" ];
            services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
            hardware.nvidia = {
                package = config.boot.kernelPackages.nvidiaPackages.stable;
                open = false; # because the video acceleration is unstable when true
                nvidiaSettings = true;
                prime = {
                    offload.enable = true;
                    offload.enableOffloadCmd = true;
                    amdgpuBusId = "PCI:102:0:0";
                    nvidiaBusId = "PCI:1:0:0";
                };
                powerManagement.enable = true;
                powerManagement.finegrained = true;
                modesetting.enable = true;
            };
        };

        nvidia-sync.configuration = { 
            services.xserver.deviceSection = ''
                Option "AllowEmptyInitialConfiguration" "on"
                Option "DRI" "3"
            '';
            
            boot.initrd.kernelModules = [
                "tun"
                "amdgpu"
                "nvidia"
                "nvidia_modeset"
                "nvidia_drm"
            ];
            
            system.nixos.tags = [ "nvidia-sync" ];
            services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
            hardware.nvidia = {
                package = config.boot.kernelPackages.nvidiaPackages.stable;
                open = false; # because the video acceleration is unstable when true
                nvidiaSettings = true;
                prime = {
                    sync.enable = true;
                    amdgpuBusId = "PCI:102:0:0";
                    nvidiaBusId = "PCI:1:0:0";
                };
                modesetting.enable = true;
            };
        };
    };

    environment.systemPackages = with pkgs; [
        libva-utils
        radeontop
        lshw
    ];
}
