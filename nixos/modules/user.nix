{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pepegov = {
    isNormalUser = true;
    description = "Pepegov";
    extraGroups = [ "networkmanager" "wheel" "dialout" "tty" "input" "tun" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };
  users.groups.tun = {};
}