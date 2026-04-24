{ config, pkgs, ... }: {
	imports = [
    	#	./modules/plasma-mime.nix
			./modules/nix-shell.nix
  	];

	home = {
		username = "pepegov";
		homeDirectory = "/home/pepegov";
		stateVersion = "25.11";

		# only for current user
		packages = with pkgs; [
			neofetch
		];
	};

	home.file."Pictures/Screenshots/.keep".text = "";

	programs.bash = {
		enable = true;
		shellAliases = {
			rebuild = "sudo nixos-rebuild switch --flake ~/nix";
		};
	};

	programs.git = {
		enable = true;
		settings.user.name = "pepegov";
		settings.user.email = "andelismore@gmail.com";
	};

	#programs.rofi = {
	#	enable = true;
		#package = pkgs.rofi-wayland; # если ты на Wayland
  	#	package = pkgs.rofi;       # если X11

  	#	extraConfig = {
    	#		modi = "drun,run";
    	#		show-icons = true;
	#		font = "JetBrainsMono Nerd Font 12";
    	#		display-drun = " Apps";
   	#		display-run = " Run";
	#		sidebar-mode = true;
	#	};
  	#	theme = "custom";
	#};

	# home.file.".config/rofi/custom.rasi".text = ''
	# * {
	# 		bg: #1e1e2e;
	# 		bg-alt: #181825;
	# 		fg: #cdd6f4;
	# 		selected: #89b4fa;
	# 		urgent: #f38ba8;

	# 		background-color: @bg;
	# 		text-color: @fg;
	# 		border: 0px;
	# 		border-radius: 16px;
	# }

	# window {
	# 		width: 40%;
	# 		padding: 20px;
	# 		background-color: @bg;
	# }

	# mainbox {
	# 		spacing: 10px;
	# }

	# inputbar {
	# 		background-color: @bg-alt;
	# 		border-radius: 12px;
	# 		padding: 10px;
	# }

	# listview {
	# 		lines: 8;
	# 		spacing: 6px;
	# 		scrollbar: false;
	# }

	# element {
	# 		padding: 8px;
	# 		border-radius: 10px;
	# }

	# element selected {
	# 		background-color: @selected;
	# 		text-color: #1e1e2e;
	# }

	# element urgent {
	# 		background-color: @urgent;
	# 		text-color: #1e1e2e;
	# }
	# '';
}
