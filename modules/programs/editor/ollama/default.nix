{
  config,
  pkgs,
  lib,
  ...
}: {
  # 1. Ensure required CLI packages are available
  home.packages = with pkgs; [
    opencode
    ollama
  ];

  # 2. Run Ollama as a user systemd service (starts on login)
  services.ollama = {
    enable = true;
    # acceleration = "rocm"; # Uncomment for AMD Radeon / ROCm support if desired
    # acceleration = "cuda"; # Uncomment for NVIDIA CUDA support
  };

  # 3. Declarative OpenCode configuration (~/.config/opencode/opencode.json)
  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";

    # Default model configuration
    model = "ollama/qwen2.5-coder:7b";

    # Configure Ollama provider endpoint
    providers = {
      ollama = {
        name = "Ollama";
        npm = "@ai-sdk/openai-compatible"; # Standard OpenAI-compatible client adapter
        options = {
          baseURL = "http://127.0.0.1:11434/v1";
        };
        models = {
          "qwen2.5-coder:7b" = {
            name = "Qwen 2.5 Coder (7B)";
            contextWindow = 32768;
            maxTokens = 8192;
          };
          "deepseek-coder-v2:16b" = {
            name = "DeepSeek Coder V2 (16B)";
            contextWindow = 65536;
            maxTokens = 8192;
          };
        };
      };
    };

    # Optional: Configure default agent roles to use local models
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
