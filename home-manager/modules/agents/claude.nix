{ pkgs, ... }:

{
  home.packages = [ pkgs.claude-code ];

  home.file = {
    ".claude/CLAUDE.md".source = ./config/common/AGENTS.md;

    ".claude/settings.json".text = builtins.toJSON {
      apiKeyHelper = "~/.local/bin/claude-freellmapi-api-key";
      env = {
        ANTHROPIC_BASE_URL = "http://127.0.0.1:3001";
        CLAUDE_CODE_API_KEY_HELPER_TTL_MS = "3600000";
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        DISABLE_AUTOUPDATER = "1";
      };
    };

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
