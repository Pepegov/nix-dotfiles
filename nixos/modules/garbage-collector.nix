{
  nix.gc = {
    automatic = true;
    date = "weekly";
    options = "--delete-older-than 30d"
  } 
}