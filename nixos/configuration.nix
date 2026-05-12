{ config, pkgs, pkgs-unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      
      # Modules
      ./modules/lock.nix
      ./modules/networking.nix
      ./modules/boot.nix
      ./modules/hardware.nix
      ./modules/session.nix
      ./modules/audio.nix
      ./modules/gpg.nix
      ./modules/virtualisation.nix
      ./modules/kdeconnect.nix
      ./modules/programming.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

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

  fonts.packages = with pkgs; [
    # обычные полезные шрифты
    noto-fonts
    noto-fonts-color-emoji

    # иконки (Font Awesome)
    font-awesome

    # для polybar-kdeconnect
    nerd-fonts.iosevka

    # Nerd Fonts конкретные
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono	

    # Microsoft
    corefonts
  ];

  # Install firefox.
  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "media.hardware-video-decoding.force-enabled" = true;
      "gfx.webrender.all" = true;
      "widget.dmabuf.force-enabled" = true;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Исправление для ассоциаций файлов в Dolphin (за пределами Plasma)
  environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
  xdg.mime.enable = true;
  xdg.menus.enable = true;  

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
	bash
	wget
	pciutils #for lspci
	git
	pass
	htop
  killall
	ffmpeg
	usbutils
	openssl
  
	mesa-demos
	zip
	unzip
  kdePackages.ark
  p7zip
	home-manager

  chromium
  clipit 
	fswebcam
	v4l-utils
  gnome-font-viewer #font view
  typora #md
	scrot # Sreenshots
	xclip # Copy screentshoot to buffer
	xed-editor
	kdePackages.dolphin # File manager
  kdePackages.kservice # For kbuildsycoca6
  kdePackages.xdg-desktop-portal-kde
  kdePackages.ffmpegthumbs
	blueberry # Bluetooth configuration tool
	alacritty # Terminal
	vlc # Video loader
	yandex-music # Music
	eartag #simple ID3 tag manager
	puddletag #ID3 tag manager
	viewnior # Photo viewer
	obs-studio
	telegram-desktop 
	obsidian 
	nextcloud-client
	qbittorrent
	blueman

    	libreoffice-qt
    	hunspell
    	hunspellDicts.uk_UA
    	hunspellDicts.ru_RU

	#phone
	android-file-transfer
	jmtpfs
  ];

services.gvfs.enable = true; #phone

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  system.stateVersion = "25.11"; # Did you read the comment?
}
