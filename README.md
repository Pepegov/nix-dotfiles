
# How to use

Update system
```bash
sudo nixos-rebuild switch --flake ~/nix --impure
```

Update home-manager
```bash
home-manager switch --flake ~/nix
```
or
```bash
home-manager switch --flake ~/nix#username
```