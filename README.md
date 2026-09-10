# How to use

Update system
```bash
sudo nixos-rebuild switch --flake ~/nix --impure
```

Update home-manager
```bash
home-manager switch --flake ~/nix --impure
```
or
```bash
home-manager switch --flake ~/nix#username --impure
```


# Rice

The bspwm session uses a dark green and cream rice with lightly rounded
surfaces. Bspwm window borders, Polybar, Rofi, Alacritty, Picom shadows, and
Polybar status scripts share the same palette. The desktop wallpaper remains
an external user preference.

| Role | Color |
| --- | --- |
| Background | `#0D0C07` |
| Background alt | `#17271C` |
| Surface | `#203828` |
| Surface hover | `#2B452F` |
| Surface active | `#39462B` |
| Foreground | `#E4D1A6` |
| Foreground bright | `#F0E6D2` |
| Foreground muted | `#A99A7C` |
| Disabled | `#817361` |
| Accent | `#D2B77C` |
| Accent secondary | `#B29570` |
| Border | `#5C4939` |
| Focused border | `#D2B77C` |
| Success | `#8EA06B` |
| Warning | `#D2B77C` |
| Error | `#C17C5D` |

Alacritty uses `#0D0C07` as its background, `#E4D1A6` as its primary text,
`#203828` for its footer panel, and `#D2B77C` for the cursor and selection.