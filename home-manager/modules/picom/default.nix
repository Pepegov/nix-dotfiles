{ ... }:

{
  home.file.".config/picom" = {
    source = ./config/picom;
    recursive = true;
  };
}
