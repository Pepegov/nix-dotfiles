{ config, pkgs, ... }:

{
    # In /etc/nixos/configuration.nix
    virtualisation.docker = {
        enable = true;
    };

    environment.systemPackages = with pkgs; [
        wineWow64Packages.stable
        winetricks
    ];
    hardware.opengl.driSupport32Bit = true;

    # virt-manager
    virtualisation.libvirtd = {
        enable = true;
        qemu.runAsRoot = false;
        onBoot = "start";
    };
    programs.virt-manager.enable = true;
    networking.firewall.trustedInterfaces = [ "virbr0" ];

    # Optional: Add your user to the "docker" group to run docker without sudo
    users.users.pepegov.extraGroups = [ "docker" "libvirtd" "kvm" ];
}