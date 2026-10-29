{ config, pkgs, lib, ... }:

let
  codexAgents = ./config/codex/agents;
  codexAgentDirectory = "${config.home.homeDirectory}/.codex/agents";
  codexSkills = ./config/common/skills;
  codexSkillDirectory = "${config.home.homeDirectory}/.codex/skills";
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

  # Codex discovers user-installed skills under $CODEX_HOME/skills
  # (normally ~/.codex/skills). Keep the shared copy above for agents that
  # use the generic ~/.agents location.
  home.file.".codex/skills" = {
    source = codexSkills;
    recursive = true;
  };

  # The Codex skill loader ignores symlinked SKILL.md files. Home Manager
  # deploys `source` entries as symlinks, so replace only these files with
  # regular copies after it has linked the generation. Do not touch .system,
  # which is maintained by Codex itself.
  home.activation.installCodexSkills = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${pkgs.coreutils}/bin/rm -f \
      "${codexSkillDirectory}/ask-clarifying-questions/SKILL.md" \
      "${codexSkillDirectory}/figma-design-to-code/SKILL.md" \
      "${codexSkillDirectory}/figma-to-avalonia/SKILL.md" \
      "${codexSkillDirectory}/vikunja-gtd-task-creator/SKILL.md"

    ${pkgs.coreutils}/bin/install -m 0644 \
      "${codexSkills}/ask-clarifying-questions/SKILL.md" \
      "${codexSkillDirectory}/ask-clarifying-questions/"

    ${pkgs.coreutils}/bin/install -m 0644 \
      "${codexSkills}/figma-design-to-code/SKILL.md" \
      "${codexSkillDirectory}/figma-design-to-code/"

    ${pkgs.coreutils}/bin/install -m 0644 \
      "${codexSkills}/figma-to-avalonia/SKILL.md" \
      "${codexSkillDirectory}/figma-to-avalonia/"

    ${pkgs.coreutils}/bin/install -m 0644 \
      "${codexSkills}/vikunja-gtd-task-creator/SKILL.md" \
      "${codexSkillDirectory}/vikunja-gtd-task-creator/"
  '';
}
