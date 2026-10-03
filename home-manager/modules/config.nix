{ config, pkgs, lib, ... }:

let
  codexAgents = ../config/agents/codex/agents;
  codexAgentDirectory = "${config.home.homeDirectory}/.codex/agents";
in

{
  home.file.".config/bspwm" = {
    source = ../config/bspwm;
    recursive = true;
  };

  home.file.".config/sxhkd" = {
    source = ../config/sxhkd;
    recursive = true;
  };

  home.file.".config/polybar" = {
    source = ../config/polybar;
    recursive = true;
  };

  home.file.".config/picom" = {
    source = ../config/picom;
    recursive = true;
  };

  home.file.".config/opencode" = {
    source = ../config/agents/opencode;
    recursive = true;
  };

  home.file.".config/opencode/AGENTS.md".source = ../config/agents/common/AGENTS.md;

  home.file.".codex/config.toml".source = ../config/agents/codex/config.toml;

  home.file.".codex/AGENTS.md".source = ../config/agents/common/AGENTS.md;

  # Codex rejects symbolic links for custom agent role files. Home Manager
  # normally deploys `source` entries as links into /nix/store, so materialize
  # these profiles as regular files during activation instead.
  home.activation.installCodexAgentProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.coreutils}/bin/install -d -m 0755 "${codexAgentDirectory}"

    ${pkgs.coreutils}/bin/rm -f \
      "${codexAgentDirectory}/code_reviewer.toml" \
      "${codexAgentDirectory}/fullstack_expert.toml" \
      "${codexAgentDirectory}/orchestrator.toml" \
      "${codexAgentDirectory}/qa_verifier.toml" \
      "${codexAgentDirectory}/security_auditor.toml"

    ${pkgs.coreutils}/bin/install -m 0644 \
      "${codexAgents}/code_reviewer.toml" \
      "${codexAgents}/fullstack_expert.toml" \
      "${codexAgents}/orchestrator.toml" \
      "${codexAgents}/qa_verifier.toml" \
      "${codexAgents}/security_auditor.toml" \
      "${codexAgentDirectory}"
  '';

  home.file.".agents/skills" = {
    source = ../config/agents/common/skills;
    recursive = true;
  };

  xdg.configFile = {
    "alacritty/alacritty.toml" = {
      source = ../config/alacritty/alacritty.toml;
      force = true;
    };
    "rofi/config.rasi".source = ../config/rofi/config.rasi;
    "rofi/theme.rasi".source = ../config/rofi/theme.rasi;
    "bspwm/rotate-monitor.sh" = {
      source = ../config/scripts/rotate-monitor.sh;
      executable = true;
    };
    "startup.sh" = {
      source = ../config/scripts/startup.sh;
      executable = true;
    };
    "wallpaper-rotate.sh" = {
      source = ../config/scripts/wallpaper-rotate.sh;
      executable = true;
    };
  };

  xdg.configFile."environment.d/env.conf".source = "${config.home.homeDirectory}/nix/hidden/enviroment.conf";
}
