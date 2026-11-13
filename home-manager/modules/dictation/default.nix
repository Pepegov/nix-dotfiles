{ pkgs, lib, ... }:

let
  whisperGpu = pkgs.whisper-cpp.override {
    cudaSupport = true;
  };
  whisperCpu = pkgs.whisper-cpp;

  dictation = pkgs.writeShellApplication {
    name = "dictation";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      libnotify
      pipewire
      procps
      xclip
      xdotool
    ];
    text = ''
      export DICTATION_WHISPER_CPU="${whisperCpu}/bin/whisper-cli"
      export DICTATION_WHISPER_GPU="${whisperGpu}/bin/whisper-cli"
      ${builtins.readFile ./dictation.sh}
    '';
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
