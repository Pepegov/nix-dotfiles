{ config, pkgs, ... }:

{
    # In /etc/nixos/configuration.nix
    virtualisation.docker = {
        enable = true;
    };

    # virt-manager
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    # Optional: Add your user to the "docker" group to run docker without sudo
    users.users.pepegov.extraGroups = [ "docker" "libvirtd" "kvm" ];
}