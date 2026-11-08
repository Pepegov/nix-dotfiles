{ ... }:

{
  programs.opencode = {
    enable = true;
    context = ./config/common/AGENTS.md;

    settings = {
      compaction = {
        auto = true;
        prune = false;
        reserved = 12000;
      };

      plugin = [
        "@dietrichgebert/ponytail"
        "superpowers@git+https://github.com/obra/superpowers.git"
      ];

      mcp = {
        browsermcp = {
          type = "local";
          command = [ "npx" "-y" "@browsermcp/mcp@latest" ];
          enabled = true;
        };
        obsidian = {
          type = "local";
          command = [ "npx" "-y" "@bitbonsai/mcpvault" "/home/pepegov/Nextcloud/PepegovDB" ];
          enabled = true;
        };
        vikunja = {
          type = "local";
          command = [ "npx" "-y" "@democratize-technology/vikunja-mcp" ];
          enabled = true;
        };

        playwright = {
          type = "local";
          command = [ "npx" "-y" "@playwright/mcp@latest" ];
          enabled = false;
        };
        chrome-devtools = {
          type = "local";
          command = [ "npx" "-y" "chrome-devtools-mcp@latest" ];
          enabled = false;
        };
        dotnet = {
          type = "local";
          command = [ "npx" "-y" "@modelcontextprotocol/server-dotnet" ];
          enabled = false;
        };
        arduino = {
          type = "local";
          command = [ "npx" "-y" "arduino-mcp-server" ];
          enabled = false;
        };
        github = {
          type = "remote";
          url = "https://api.githubcopilot.com/mcp/";
          oauth = false;
          headers = {
            Authorization = "Bearer {env:GITHUB_PERSONAL_ACCESS_TOKEN}";
            X-MCP-Toolsets = "default,actions";
          };
          enabled = false;
        };
        gitlab = {
          type = "local";
          command = [ "bash" "-lc" "GITLAB_PERMISSION_MODE=modify exec npx -y @zereight/mcp-gitlab@2.3.4" ];
          environment = {
            GITLAB_PERSONAL_ACCESS_TOKEN = "{env:GITLAB_PERSONAL_ACCESS_TOKEN}";
            GITLAB_API_URL = "{env:GITLAB_API_URL}";
          };
          enabled = false;
        };
        figma = {
          type = "local";
          command = [ "bunx" "figma-mcp-server" ];
          enabled = false;
        };
        avalonia = {
          type = "remote";
          url = "https://docs-mcp.avaloniaui.net/mcp";
          enabled = false;
        };
        rider = {
          type = "remote";
          url = "http://127.0.0.1:64482/stream";
          enabled = false;
        };
      };

      provider.ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama";

        options = {
          baseURL = "http://127.0.0.1:11434/v1";
        };

        models = {
          "qwen3.6:35b" = {
            name = "Qwen3.6 35B (Local)";

            limit = {
              context = 65536;
              output = 8192;
            };
          };

        };
      };
    };
  };
}
