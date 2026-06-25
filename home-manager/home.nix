{ config, pkgs, ... }: {
	imports = [
    	#	./modules/plasma-mime.nix
			./modules/nix-shell.nix
			./modules/git.nix
			./modules/config.nix
			#./modules/vscode.nix
			./modules/apps.nix
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
			rebuild = "sudo nixos-rebuild switch --flake ~/nix --impure";
			vpn-work-up   = "sudo systemctl start openvpn-work && sudo systemctl start openvpn-work-infra";
  		vpn-work-down = "sudo systemctl stop openvpn-work && sudo systemctl stop openvpn-work-infra";
		};
	};
}
