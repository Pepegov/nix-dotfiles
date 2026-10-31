{ config, pkgs, pkgs-unstable, inputs, ... }:

{
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

  environment.systemPackages = with pkgs; [
    bash
    wget
    pciutils #for lspci
    git
    pass
    killall
    ffmpeg
    usbutils
    openssl
    
    htop
    btop

    #ai
    openai-whisper
    pkgs-unstable.codex
    
    mesa-demos
    zip
    unzip
    rar
    unrar
    kdePackages.ark
    p7zip
    home-manager

    chromium
    xfce4-clipman-plugin
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
    blueman # Bluetooth configuration tool
    alacritty # Terminal
    atril # PDF reader
    vlc # Video loader
    yandex-music # Music
    eartag #simple ID3 tag manager
    puddletag #ID3 tag manager
    viewnior # Photo viewer
    bind #nslookup
    obs-studio
    telegram-desktop 
    ayugram-desktop
    pkgs-unstable.obsidian 
    nextcloud-client
    qbittorrent
    blueman

    #libreoffice
    libreoffice-qt
    hunspell
    hunspellDicts.uk_UA
    hunspellDicts.ru_RU

    #phone
    android-file-transfer
    jmtpfs
  ];

  #email
  programs.evolution = {
    enable = true;
    plugins = with pkgs; [
      evolution-ews
    ];
  };

  services.gvfs.enable = true; #phone

  programs.calendarflow.enable = true;
}
