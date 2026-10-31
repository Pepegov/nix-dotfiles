{ config, pkgs, ... }: {
	imports = [
			./modules/agents
			./modules/alacritty
			./modules/apps
			./modules/bspwm
			./modules/delayed-shutdown
			./modules/dictation
			./modules/dunst
			./modules/environment
			./modules/git
			./modules/night-mode
			./modules/nix-shell
			./modules/picom
			./modules/plasma-mime
			./modules/polybar
			./modules/rofi
			./modules/rotate-monitor
			./modules/theme
			./modules/vscode
			./modules/wallpaper
  	];

	home = {
		username = "pepegov";
		homeDirectory = "/home/pepegov";
		stateVersion = "26.05";

		# only for current user
		packages = with pkgs; [
			fastfetch
			feh
		];
	};
	home.file."Pictures/Screenshots/.keep".text = "";
	programs.bash = {
		enable = true;
		shellAliases = {
			rebuild-nix = "sudo nixos-rebuild boot --flake ~/nix --impure";
            rebuild-home-manager = "home-manager switch --impure --flake ~/nix";
		};
	};
}
