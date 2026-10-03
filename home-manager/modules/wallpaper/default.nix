{ ... }:

{
  home.file."Pictures/Wallpapers" = {
    source = ./assets/desktop;
    recursive = true;
  };

  xdg.configFile."wallpaper-rotate.sh" = {
    source = ./config/wallpaper-rotate.sh;
    executable = true;
  };
}
