{ config, ... }:

{
  programs.pi-coding-agent = {
    enable = true;
    context = ./config/common/AGENTS.md;

    settings = {
      compaction = {
        enabled = true;
        reserveTokens = 12000;
      };

      skills = [ "${config.home.homeDirectory}/.agents/skills" ];
    };

    models = {
      providers.ollama = {
        name = "Ollama";
        baseUrl = "http://127.0.0.1:11434/v1";
        api = "openai-completions";
        apiKey = "ollama";

        models = [
          {
            id = "qwen3.5:9b";
            name = "Qwen3.5 9B (Local)";
            contextWindow = 40960;
            maxTokens = 8192;
          }
          {
            id = "qwen3:8b";
            name = "Qwen3 8B (Local)";
            contextWindow = 40960;
            maxTokens = 8192;
          }
        ];
      };
    };
  };

  home.file.".pi/agent/mcp.json".text = builtins.toJSON {
    mcpServers = {
      browsermcp = {
        command = "npx";
        args = [ "-y" "@browsermcp/mcp@latest" ];
        enabled = true;
        exposure = "direct";
      };
      obsidian = {
        command = "npx";
        args = [ "-y" "@bitbonsai/mcpvault" "/home/pepegov/Nextcloud/PepegovDB" ];
        enabled = true;
        exposure = "direct";
      };
      vikunja = {
        command = "npx";
        args = [ "-y" "@democratize-technology/vikunja-mcp" ];
        enabled = true;
        exposure = "direct";
      };
      firefly-iii = {
        command = "bunx";
        args = [ "-y" "@firefly-iii-mcp/local" "--baseUrl" "https://firefly.pepegov.ru" ];
        env = {
          FIREFLY_III_PAT = "\${FIREFLY_III_PAT}";
          FIREFLY_III_BASE_URL = "\${FIREFLY_III_BASE_URL}";
        };
        enabled = true;exposure = "direct";
      };
      playwright = {
        command = "npx";
        args = [ "-y" "@playwright/mcp@latest" ];
        enabled = false;
        exposure = "direct";
      };
      chrome-devtools = {
        command = "npx";
        args = [ "-y" "chrome-devtools-mcp@latest" ];
        enabled = false;
        exposure = "direct";
      };
      dotnet = {
        command = "npx";
        args = [ "-y" "@modelcontextprotocol/server-dotnet" ];
        enabled = false;
        exposure = "direct";
      };
      arduino = {
        command = "npx";
        args = [ "-y" "arduino-mcp-server" ];
        enabled = false;
        exposure = "direct";
      };
      github = {
        url = "https://api.githubcopilot.com/mcp/";
        headers = {
          Authorization = "Bearer \${GITHUB_PERSONAL_ACCESS_TOKEN}";
          X-MCP-Toolsets = "default,actions";
        };
        enabled = false;
        exposure = "direct";
      };
      gitlab = {
        command = "bash";
        args = [ "-lc" "GITLAB_PERMISSION_MODE=modify exec npx -y @zereight/mcp-gitlab@2.3.4" ];
        env = {
          GITLAB_PERSONAL_ACCESS_TOKEN = "\${GITLAB_PERSONAL_ACCESS_TOKEN}";
          GITLAB_API_URL = "\${GITLAB_API_URL}";
        };
        enabled = false;
        exposure = "direct";
      };
      figma = {
        command = "bunx";
        args = [ "figma-mcp-server" ];
        enabled = false;
        exposure = "direct";
      };
      avalonia = {
        url = "https://docs-mcp.avaloniaui.net/mcp";
        enabled = false;
        exposure = "direct";
      };
    };
  };
}
