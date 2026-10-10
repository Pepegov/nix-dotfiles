{ ... }:

{
  home.file.".config/environment/load-local-env.sh" = {
    text = ''
      local_env_file="$HOME/nix/hidden/enviroment.conf"

      if [ -r "$local_env_file" ]; then
        set -a
        . "$local_env_file"
        set +a
      fi
    '';
    executable = true;
  };

  programs.bash = {
    bashrcExtra = ''
      . "$HOME/.config/environment/load-local-env.sh"
    '';
    profileExtra = ''
      . "$HOME/.config/environment/load-local-env.sh"
    '';
  };
}
