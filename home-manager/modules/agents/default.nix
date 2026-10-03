{ config, pkgs, lib, ... }:

let
  codexAgents = ./config/codex/agents;
  codexAgentDirectory = "${config.home.homeDirectory}/.codex/agents";
in
{
  home.file.".config/opencode" = {
    source = ./config/opencode;
    recursive = true;
  };

  home.file.".config/opencode/AGENTS.md".source = ./config/common/AGENTS.md;
  home.file.".codex/config.toml".source = ./config/codex/config.toml;
  home.file.".codex/AGENTS.md".source = ./config/common/AGENTS.md;

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
    source = ./config/common/skills;
    recursive = true;
  };
}
