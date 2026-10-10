{ pkgs, lib, ... }:

let
  dictation = pkgs.writeShellApplication {
    name = "dictation";
    runtimeInputs = with pkgs; [
      coreutils
      libnotify
      openai-whisper
      pipewire
      procps
      xclip
      xdotool
    ];
    text = builtins.readFile ./dictation.sh;
  };
in
{
  home.packages = [ dictation ];

  # BSPWM does not otherwise start a notification daemon.
  services.dunst.enable = true;

  home.activation.reloadSxhkd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ${pkgs.procps}/bin/pgrep -x sxhkd >/dev/null; then
      $DRY_RUN_CMD ${pkgs.procps}/bin/pkill -USR1 -x sxhkd
    fi
  '';
}
