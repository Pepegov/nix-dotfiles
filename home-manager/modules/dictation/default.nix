{ pkgs, lib, ... }:

let
  whisper = pkgs.whisper-cpp.override {
    cudaSupport = true;
  };

  dictation = pkgs.writeShellApplication {
    name = "dictation";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      libnotify
      pipewire
      procps
      whisper
      xclip
      xdotool
    ];
    text = builtins.readFile ./dictation.sh;
  };
in
{
  home.packages = [ dictation ];

  home.activation.reloadSxhkd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ${pkgs.procps}/bin/pgrep -x sxhkd >/dev/null; then
      $DRY_RUN_CMD ${pkgs.procps}/bin/pkill -USR1 -x sxhkd
    fi
  '';
}
