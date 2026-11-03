{ config, lib, pkgs, inputs, ... }:

# Native Home Manager configuration for Codex.

let
  # Ponytail is distributed as a skill, so package it as a minimal Codex plugin.
  ponytailPlugin = pkgs.runCommand "ponytail" { } ''
    mkdir -p "$out/.codex-plugin" "$out/skills/ponytail"
    cp -R ${inputs.ponytail}/skills/ponytail/. "$out/skills/ponytail"
    cp ${pkgs.writeText "ponytail-plugin.json" (builtins.toJSON {
      name = "ponytail";
      version = "1.0.0";
      description = "Lazy senior development workflow.";
      skills = "./skills/";
    })} "$out/.codex-plugin/plugin.json"
  '';

  codexAgents = ./config/codex/agents;
  codexAgentDirectory = "${config.home.homeDirectory}/.codex/agents";
in
{
  programs.codex = {
    enable = true;
    context = ./config/common/AGENTS.md;
    skills = ./config/common/skills;
    plugins = [
      ponytailPlugin
      inputs.superpowers
    ];

    settings = {
      approval_policy = "never";
      model = "gpt-5.6-terra";
      model_reasoning_effort = "medium";
      personality = "pragmatic";
      sandbox_mode = "danger-full-access";
      notice = {
        hide_rate_limit_model_nudge = true;
      };

      agents = {
        enabled = true;
        max_concurrent_threads_per_session = 4;
      };

      features = {
        multi_agent = true;
        multi_agent_v2 = true;
        rmcp_client = true;
      };

      mcp_servers = {
        arduino = {
          args = [ "-y" "arduino-mcp-server" ];
          command = "npx";
          enabled = false;
        };
        avalonia = {
          enabled = true;
          url = "https://docs-mcp.avaloniaui.net/mcp";
        };
        browsermcp = {
          args = [ "-y" "@browsermcp/mcp@latest" ];
          command = "npx";
          enabled = true;
        };
        chrome-devtools = {
          args = [ "-y" "chrome-devtools-mcp@latest" "--executablePath" "/run/current-system/sw/bin/chromium" ];
          command = "npx";
          enabled = true;
        };
        dotnet = {
          args = [ "-y" "@modelcontextprotocol/server-dotnet" ];
          command = "npx";
          enabled = false;
        };
        figma = {
          args = [ "figma-mcp-server" ];
          command = "bunx";
          enabled = false;
          env_vars = [ "FIGMA_API_KEY" ];
        };
        github = {
          bearer_token_env_var = "GITHUB_PERSONAL_ACCESS_TOKEN";
          enabled = true;
          headers = {
            X-MCP-Toolsets = "default,actions";
          };
          url = "https://api.githubcopilot.com/mcp/";
        };
        gitlab = {
          args = [ "-lc" "GITLAB_PERMISSION_MODE=modify exec npx -y @zereight/mcp-gitlab@2.3.4" ];
          command = "bash";
          enabled = true;
          env_vars = [ "GITLAB_PERSONAL_ACCESS_TOKEN" "GITLAB_API_URL" ];
        };
        obsidian = {
          args = [ "-y" "@bitbonsai/mcpvault" "/home/pepegov/Nextcloud/PepegovDB" ];
          command = "npx";
          enabled = true;
        };
        playwright = {
          args = [ "-y" "@playwright/mcp@latest" "--executable-path" "/run/current-system/sw/bin/chromium" ];
          command = "npx";
          enabled = true;
        };
        rider = {
          enabled = true;
          url = "http://127.0.0.1:64482/stream";
        };
        vikunja = {
          args = [ "-y" "@0xk3vin/vikunja-mcp" ];
          command = "npx";
          enabled = true;
          env_vars = [ "VIKUNJA_URL" "VIKUNJA_API_TOKEN" ];
        };
      };

      projects = {
        "/home/pepegov".trust_level = "untrusted";
        "/home/pepegov/nix".trust_level = "trusted";
        "/home/pepegov/repositoryes/GITHUB/Template.Net.Monolith.Modular".trust_level = "trusted";
        "/home/pepegov/repositoryes/Private_GitHub/CalendarFlow".trust_level = "trusted";
        "/home/pepegov/repositoryes/Private_GitHub/NFCPOS".trust_level = "trusted";
        "/home/pepegov/repositoryes/Private_GitHub/nixos_crypto".trust_level = "trusted";
        "/home/pepegov/repositoryes/Umbrella/ansible".trust_level = "trusted";
        "/home/pepegov/repositoryes/Umbrella/management-center".trust_level = "trusted";
        "/home/pepegov/repositoryes/GITHUB/yt-dlp-downloader".trust_level = "trusted";
      };
    };
  };

  # These directories were managed by the previous skills setup. Let the
  # native programs.codex.skills module replace only its own old entries.
  home.file.".codex/skills/ask-clarifying-questions".force = true;
  home.file.".codex/skills/figma-design-to-code".force = true;
  home.file.".codex/skills/figma-to-avalonia".force = true;
  home.file.".codex/skills/vikunja-gtd-task-creator".force = true;
  home.file.".codex/skills/prd-writing".force = true;
  home.file.".codex/skills/ui-designer".force = true;
  home.file.".codex/skills/spec-from-screenshot".force = true;

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

  # Codex materializes these Home Manager-managed links as directories.
  home.activation.cleanManagedCodexArtifacts = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    ${pkgs.coreutils}/bin/rm -rf \
      "${config.home.homeDirectory}/.agents/plugins/superpowers" \
      "${config.home.homeDirectory}/.agents/plugins/ponytail" \
      "${config.home.homeDirectory}/.codex/plugins/cache/home-manager/superpowers/local" \
      "${config.home.homeDirectory}/.codex/plugins/cache/home-manager/ponytail/local" \
      "${config.home.homeDirectory}/.codex/skills/ask-clarifying-questions" \
      "${config.home.homeDirectory}/.codex/skills/figma-design-to-code" \
      "${config.home.homeDirectory}/.codex/skills/figma-to-avalonia" \
      "${config.home.homeDirectory}/.codex/skills/vikunja-gtd-task-creator"
  '';
}
