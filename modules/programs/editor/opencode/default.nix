{ pkgs, ... }:

{
  home-manager.sharedModules = [
    (
      { config, lib, ... }:
      {
        # 1. Packages for terminal agent & local model runner
        home.packages = with pkgs; [
          opencode
          ollama
        ];

        # 2. User-level systemd service for Ollama daemon
        services.ollama = {
          enable = true;
        };

        # 3. Create a real physical file instead of a Nix symlink
        home.activation.writeOpenCodeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
          mkdir -p $HOME/.config/opencode
          cat << 'EOF' > $HOME/.config/opencode/opencode.json
          {
            "$schema": "https://opencode.ai/config.json",
            "model": "local/qwen2.5-coder:7b",
            "provider": {
              "local": {
                "name": "Ollama",
                "npm": "@ai-sdk/openai-compatible",
                "options": {
                  "baseURL": "http://127.0.0"
                },
                "models": {
                  "qwen2.5-coder:7b": {
                    "name": "Qwen 2.5 Coder (7B)",
                    "contextWindow": 32768,
                    "maxTokens": 8192
                  }
                }
              }
            },
            "agents": {
              "build": {
                "model": "local/qwen2.5-coder:7b"
              },
              "plan": {
                "model": "local/qwen2.5-coder:7b"
              }
            }
          }
          EOF
        '';
      }
    )
  ];
}
