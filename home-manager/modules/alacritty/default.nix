{ ... }:

{
  xdg.configFile."alacritty/alacritty.toml" = {
    source = ./config/alacritty.toml;
    force = true;
  };
}
