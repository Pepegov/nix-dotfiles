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

    # NVIDIA sync is the normal desktop mode: Xorg and the GL driver set use
    # the same GPU, so an ordinary `nixos-rebuild switch` is safe.
    services.xserver.deviceSection = lib.mkDefault ''
        Option "AllowEmptyInitialConfiguration" "on"
        Option "DRI" "3"
    '';
    services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
    boot.initrd.kernelModules = [
        "tun"
        "amdgpu"
    ];
    system.nixos.tags = lib.mkDefault [ "nvidia-sync" ];
    hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        open = false; # because the video acceleration is unstable when true
        nvidiaSettings = true;
        prime = {
            sync.enable = lib.mkDefault true;
            amdgpuBusId = "PCI:102:0:0";
            nvidiaBusId = "PCI:1:0:0";
        };
        modesetting.enable = true;
    };

    specialisation = {
        nvidia-offload.configuration = {
            services.xserver.deviceSection = ''
                Option "DRI" "2"
            '';

            boot.initrd.kernelModules = [
                "tun"
                "amdgpu"
                "nvidia"
                "nvidia_modeset"
                "nvidia_drm"
            ];

            system.nixos.tags = [ "nvidia-offload" ];
            hardware.nvidia = {
                prime = {
                    sync.enable = lib.mkForce false;
                    offload.enable = true;
                    offload.enableOffloadCmd = true;
                    amdgpuBusId = "PCI:102:0:0";
                    nvidiaBusId = "PCI:1:0:0";
                };
                powerManagement.enable = true;
                powerManagement.finegrained = true;
            };
        };
    };

    environment.systemPackages = with pkgs; [
        libva-utils
        radeontop
        lshw
        # cudatoolkit
        # cudaPackages.cudnn
    ];
}
