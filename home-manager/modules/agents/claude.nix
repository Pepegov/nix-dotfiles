{ pkgs, inputs, ... }:

let
  ponytailPlugin = pkgs.runCommand "claude-ponytail-plugin" { } ''
    mkdir -p "$out/.claude-plugin" "$out/skills/ponytail"
    cp -R \${inputs.ponytail}/skills/ponytail/. "$out/skills/ponytail"
    cp \${pkgs.writeText "claude-ponytail-plugin.json" (builtins.toJSON {
      name = "ponytail";
      version = "1.0.0";
      description = "Lazy senior development workflow.";
    })} "$out/.claude-plugin/plugin.json"
  '';
in
{
  programs.claude-code = {
    enable = true;
    context = ./config/common/AGENTS.md;
    skills = ./config/common/skills;
    plugins = {
      ponytail = ponytailPlugin;
      superpowers = inputs.superpowers;
    };

    mcpServers = {
      arduino = {
        type = "stdio";
        command = "npx";
        args = [ "-y" "arduino-mcp-server" ];
        enabled = false;
      };
      avalonia = {
        type = "http";
        url = "https://docs-mcp.avaloniaui.net/mcp";
      };
      browsermcp = {
        type = "stdio";
        command = "npx";
        args = [ "-y" "@browsermcp/mcp@latest" ];
      };
      chrome-devtools = {
        type = "stdio";
        command = "npx";
        args = [ "-y" "chrome-devtools-mcp@latest" "--executablePath" "/run/current-system/sw/bin/chromium" ];
      };
      dotnet = {
        type = "stdio";
        command = "npx";
        args = [ "-y" "@modelcontextprotocol/server-dotnet" ];
        enabled = false;
      };
      figma = {
        type = "stdio";
        command = "bunx";
        args = [ "figma-mcp-server" ];
        env.FIGMA_API_KEY = "\${FIGMA_API_KEY}";
        enabled = false;
      };
      github = {
        type = "http";
        url = "https://api.githubcopilot.com/mcp/";
        headers = {
          Authorization = "Bearer \${GITHUB_PERSONAL_ACCESS_TOKEN}";
          X-MCP-Toolsets = "default,actions";
        };
      };
      gitlab = {
        type = "stdio";
        command = "bash";
        args = [ "-lc" "GITLAB_PERMISSION_MODE=modify exec npx -y @zereight/mcp-gitlab@2.3.4" ];
        env = {
          GITLAB_PERSONAL_ACCESS_TOKEN = "\${GITLAB_PERSONAL_ACCESS_TOKEN}";
          GITLAB_API_URL = "\${GITLAB_API_URL}";
        };
      };
      obsidian = {
        type = "stdio";
        command = "npx";
        args = [ "-y" "@bitbonsai/mcpvault" "/home/pepegov/Nextcloud/PepegovDB" ];
      };
      playwright = {
        type = "stdio";
        command = "npx";
        args = [ "-y" "@playwright/mcp@latest" "--executable-path" "/run/current-system/sw/bin/chromium" ];
      };
      rider = {
        type = "sse";
        url = "http://127.0.0.1:64482/stream";
      };
      vikunja = {
        type = "stdio";
        command = "npx";
        args = [ "-y" "@0xk3vin/vikunja-mcp" ];
        env = {
          VIKUNJA_URL = "\${VIKUNJA_URL}";
          VIKUNJA_API_TOKEN = "\${VIKUNJA_API_TOKEN}";
        };
      };
    };

    settings = {
      apiKeyHelper = "~/.local/bin/claude-freellmapi-api-key";
      env = {
        ANTHROPIC_BASE_URL = "http://localhost:3001";
        CLAUDE_CODE_API_KEY_HELPER_TTL_MS = "3600000";
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        DISABLE_AUTOUPDATER = "1";
      };
    };
  };

  home.file = {
    ".local/bin/claude-freellmapi-api-key" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        source "$HOME/.config/environment/load-local-env.sh"

        if [[ -z "''${FREELLMAPI_API_KEY:-}" ]]; then
          echo "FREELLMAPI_API_KEY is not set in ~/nix/hidden/enviroment.conf" >&2
          exit 1
        fi

        printf '%s\n' "$FREELLMAPI_API_KEY"
      '';
    };
  };
}
