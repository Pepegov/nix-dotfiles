{ config, pkgs, ... }:

{
  # Включаем поддержку MIME-приложений
  xdg.mimeApps.enable = true;
  
  # Настройка приложений по умолчанию для разных типов файлов
  xdg.mimeApps.defaultApplications = {
    # Текстовые файлы - xed
    "text/plain" = "xed.desktop";
    "text/markdown" = "xed.desktop";
    "text/x-log" = "xed.desktop";
    "text/x-python" = "xed.desktop";
    "text/x-java" = "xed.desktop";
    "text/x-c" = "xed.desktop";
    "text/x-c++" = "xed.desktop";
    "text/x-tex" = "xed.desktop";
    "text/xml" = "xed.desktop";
    "text/css" = "xed.desktop";
    "text/javascript" = "xed.desktop";
    "text/x-shellscript" = "xed.desktop";
    
    # Видео файлы - VLC
    "video/mp4" = "vlc.desktop";
    "video/mpeg" = "vlc.desktop";
    "video/x-matroska" = "vlc.desktop";
    "video/webm" = "vlc.desktop";
    "video/ogg" = "vlc.desktop";
    "video/quicktime" = "vlc.desktop";
    "video/x-msvideo" = "vlc.desktop";
    "video/x-flv" = "vlc.desktop";
    "video/x-ms-wmv" = "vlc.desktop";
    "video/3gpp" = "vlc.desktop";
    "video/dv" = "vlc.desktop";
    "video/mpv" = "vlc.desktop";
    
    # Изображения - Viewnior
    "image/jpeg" = "viewnior.desktop";
    "image/jpg" = "viewnior.desktop";
    "image/pjpeg" = "viewnior.desktop";
    "image/png" = "viewnior.desktop";
    "image/gif" = "viewnior.desktop";
    "image/bmp" = "viewnior.desktop";
    "image/tiff" = "viewnior.desktop";
    "image/svg+xml" = "viewnior.desktop";
    "image/svg+xml-compressed" = "viewnior.desktop";
    "image/vnd.wap.wbmp" = "viewnior.desktop";
    "image/x-bmp" = "viewnior.desktop";
    "image/x-gray" = "viewnior.desktop";
    "image/x-icb" = "viewnior.desktop";
    "image/x-ico" = "viewnior.desktop";
    "image/x-png" = "viewnior.desktop";
    "image/x-portable-anymap" = "viewnior.desktop";
    "image/x-portable-bitmap" = "viewnior.desktop";
    "image/x-portable-graymap" = "viewnior.desktop";
    "image/x-portable-pixmap" = "viewnior.desktop";
    "image/x-xbitmap" = "viewnior.desktop";
    "image/x-xpixmap" = "viewnior.desktop";
    "image/x-pcx" = "viewnior.desktop";
    
    # PDF - браузер (Firefox/Chromium)
    "application/pdf" = [
      "firefox.desktop"
    ];
  };
}
