;{ ... }:

{
  programs.opencode = {
    enable = true;
    context = ./config/common/AGENTS.md;

    settings = {
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
        playwright = {
          type = "local";
          command = [ "npx" "-y" "@playwright/mcp@latest" ];
          enabled = true;
        };
        chrome-devtools = {
          type = "local";
          command = [ "npx" "-y" "chrome-devtools-mcp@latest" ];
          enabled = true;
        };
        obsidian = {
          type = "local";
          command = [ "npx" "-y" "@bitbonsai/mcpvault" "/home/pepegov/Nextcloud/PepegovDB" ];
          enabled = true;
        };
        dotnet = {
          type = "local";
          command = [ "npx" "-y" "@modelcontextprotocol/server-dotnet" ];
          enabled = true;
        };
        arduino = {
          type = "local";
          command = [ "npx" "-y" "arduino-mcp-server" ];
          enabled = true;
        };
        github = {
          type = "local";
          command = [ "npx" "-y" "@modelcontextprotocol/server-github" ];
          enabled = true;
        };
        gitlab = {
          type = "local";
          command = [ "bash" "-lc" "GITLAB_PERMISSION_MODE=modify exec npx -y @zereight/mcp-gitlab@2.3.4" ];
          environment = {
            GITLAB_PERSONAL_ACCESS_TOKEN = "{env:GITLAB_PERSONAL_ACCESS_TOKEN}";
            GITLAB_API_URL = "{env:GITLAB_API_URL}";
          };
          enabled = true;
        };
        vikunja = {
          type = "local";
          command = [ "npx" "-y" "@democratize-technology/vikunja-mcp" ];
          enabled = true;
        };
        figma = {
          type = "local";
          command = [ "bunx" "figma-mcp-server" ];
        };
        avalonia = {
          type = "remote";
          url = "https://docs-mcp.avaloniaui.net/mcp";
        };
        rider = {
          type = "remote";
          url = "http://127.0.0.1:64482/stream";
        };
      };

      provider.lmstudio = {
        npm = "@ai-sdk/openai-compatible";
        name = "LM Studio (local)";
        options.baseURL = "http://127.0.0.1:1234/v1";
      };
    };
  };
}
