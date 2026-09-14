{ pkgs, ... }:

{
  home-manager.sharedModules = [
    (
      { config, ... }:
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

        # 3. Declarative OpenCode configuration (~/.config/opencode/opencode.json)
        xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
          "$schema" = "https://opencode.ai/config.json";

          # Active model pointer using Ollama's auto-discovered model ID
          model = "ollama/qwen2.5-coder:7b";

          # Compatibility for v1 engine
          provider = {
            ollama = {
              name = "Ollama";
              npm = "@ai-sdk/openai-compatible";
              options = {
                baseURL = "http://127.0.0.1:11434/v1"; # Added /v1 suffix
              };
              models = {
                "qwen2.5-coder:7b" = { name = "Qwen 2.5 Coder (7B)"; contextWindow = 32768; maxTokens = 8192; };
              };
            };
          };

          # Compatibility for v2 engine
          providers = {
            ollama = {
              name = "Ollama";
              package = "@opencode/ai/providers/openai-compatible";
              settings = {
                baseURL = "http://127.0.0.1:11434/v1"; # Added /v1 suffix
              };
              models = {
                "qwen2.5-coder:7b" = { name = "Qwen 2.5 Coder (7B)"; contextWindow = 32768; maxTokens = 8192; };
              };
            };
          };

          # Route built-in primary agents to the local model
          agents = {
            build = {
              model = "ollama/qwen2.5-coder:7b";
            };
            plan = {
              model = "ollama/qwen2.5-coder:7b";
            };
          };
        };
      }
    )
  ];
}
