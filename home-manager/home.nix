{ config, pkgs, ... }: {
	imports = [
			./modules/agents
			./modules/alacritty
			./modules/apps
			./modules/bspwm
			./modules/git
			./modules/night-mode
			./modules/nix-shell
			./modules/picom
			./modules/plasma-mime
			./modules/polybar
			./modules/rofi
			./modules/rotate-monitor
			./modules/theme
			# ./modules/vscode
			./modules/wallpaper
  	];

	home = {
		username = "pepegov";
		homeDirectory = "/home/pepegov";
		stateVersion = "25.11";

		# only for current user
		packages = with pkgs; [
			neofetch
			feh
		];
	};
	home.file."Pictures/Screenshots/.keep".text = "";
	programs.bash = {
		enable = true;
		shellAliases = {
			rebuild = "sudo nixos-rebuild switch --flake ~/nix --impure";
			vpn-work-up   = "sudo systemctl start openvpn-work && sudo systemctl start openvpn-work-infra";
  		vpn-work-down = "sudo systemctl stop openvpn-work && sudo systemctl stop openvpn-work-infra";
		};
	};
}
