# How to use

Update system
```bash
sudo nixos-rebuild switch --flake ~/nix --impure
```

## NVIDIA modes

`nvidia-sync` is the default mode. NVIDIA drives the displays, so the regular
system update command above keeps Xorg and `/run/opengl-driver` on the same
driver set.

`nvidia-offload` is an optional specialisation. It keeps AMD as the display
GPU and uses NVIDIA only for applications explicitly launched through PRIME
offload:

```bash
sudo /run/current-system/specialisation/nvidia-offload/bin/switch-to-configuration switch
```

Switching between sync and offload changes the GPU that owns the Xorg display.
End the graphical session and start a new one after such a switch. Do not run
the base configuration over an active offload session, or GL applications can
receive libraries for a different GPU and fail with errors such as:

```text
Error: "failed to find suitable GL configuration."
```

```bash
sudo nixos-rebuild switch --flake ~/nix --impure
```

This restores the default NVIDIA sync mode.

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
