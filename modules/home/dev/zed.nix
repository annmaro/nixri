{ config, lib, pkgs, ... }:

{
  # Keep Zed installed as an alternate editor.
  home.packages = [ pkgs.zed-editor ];

  programs.zed-editor = lib.mkIf (config.homeSettings.editor == "zed") {
        enable = true;

        extensions = [
          "nix"
          "toml"
          "rust"
          "python"
          "cpp"
          "qml"
          "gruvbox-material"
          "zed-min-theme"
        ];

        userKeymaps = [
          {
            context = "Editor && vim_mode == normal && !menu";
            bindings = {
              # Buffer navigation
              "shift-h" = "pane::ActivatePrevItem";
              "shift-l" = "pane::ActivateNextItem";

              # Splits
              "space v" = "pane::SplitRight";
              "space s" = "pane::SplitDown";

              # Pane navigation
              "ctrl-h" = "workspace::ActivatePaneLeft";
              "ctrl-l" = "workspace::ActivatePaneRight";
              "ctrl-k" = "workspace::ActivatePaneUp";
              "ctrl-j" = "workspace::ActivatePaneDown";

              # File & Buffer actions
              "space w" = "workspace::Save";
              "space q" = "pane::CloseActiveItem";
              "space f" = "file_finder::Toggle";
              "space p" = "editor::Format";
              "space c a" = "editor::ToggleCodeActions";

              # Diagnostics & hover
              "[ d" = "editor::GoToPreviousDiagnostic";
              "] d" = "editor::GoToDiagnostic";
              "g h" = "editor::Hover";

              # Project drawer / sidebar toggle
              "ctrl-n" = "project_panel::ToggleFocus";

              # AI / Agent Chat History
              "space a h" = "agents_sidebar::ToggleThreadHistory";
              "space a s" = "agents_sidebar::ToggleThreadSwitcher";
            };
          }
          {
            context = "Editor && vim_mode == insert";
            bindings = {
              "k j" = "vim::NormalBefore";
              "ctrl-shift-v" = "editor::Paste";
            };
          }
          {
            context = "Editor && vim_mode == visual";
            bindings = {
              # Terminal-style Copy
              "ctrl-shift-c" = "editor::Copy";

              "<" = "editor::Outdent";
              ">" = "editor::Indent";
              "shift-j" = "editor::MoveLineDown";
              "shift-k" = "editor::MoveLineUp";
              "space c" = "editor::ToggleComments";
            };
          }
          {
            # Global fallback for Copy / Chat History anywhere in the workspace
            context = "Workspace";
            bindings = {
              "ctrl-alt-h" = "agents_sidebar::ToggleThreadHistory";
            };
          }
        ];

        userSettings = {
          vim_mode = true;
          theme = {
            mode = "dark";
            dark = "Gruvbox Material";
            light = "Gruvbox Material";
          };
          icon_theme = "Min Theme";

          buffer_font_size = 24;
          relative_line_numbers = true;
          show_whitespaces = "selection";

          # Zeta Predictions & Completion UI
          show_completions_on_input = true;
          show_completion_documentation = true;
          edit_predictions = {
            provider = "zed";
          };

          # Modern formatting schema
          formatter = "language_server";
          auto_format = true;

          telemetry = {
            diagnostics = false;
            metrics = false;
          };

          inlay_hints = {
            enabled = true;
            show_type_hints = true;
            show_parameter_hints = true;
          };

          # MCP Context Servers
          context_servers = {
            nixos = {
              command = "${pkgs.uv}/bin/uvx";
              args = [
                "--install-deps"
                "mcp-nixos"
              ];
            };
          };

          # Model Providers (Local Ollama, Gemini, and OpenRouter via openai_compatible)
          language_models = {
            ollama = {
              api_url = "http://localhost:11434";
              auto_discover = true;
            };

            # Google AI — API key via GEMINI_API_KEY env var or Settings > AI > LLM Providers
            google = {
              available_models = [
                {
                  name = "gemini-3.1-pro-preview";
                  display_name = "Gemini 3.1 Pro Preview";
                  max_tokens = 1000000;
                }
                {
                  name = "gemini-2.5-pro";
                  display_name = "Gemini 2.5 Pro";
                  max_tokens = 1000000;
                }
              ];
            };

            # OpenRouter — latest schema: use openai_compatible, not the deprecated open_router key
            # API key via OPENROUTER_API_KEY env var or Settings > AI > LLM Providers
            openai_compatible = {
              OpenRouter = {
                api_url = "https://openrouter.ai/api/v1";
                available_models = [
                  {
                    name = "deepseek/deepseek-chat:free";
                    display_name = "DeepSeek V3 (Free)";
                    max_tokens = 64000;
                  }
                  {
                    name = "qwen/qwen-2.5-coder-32b-instruct:free";
                    display_name = "Qwen 2.5 Coder 32B (Free)";
                    max_tokens = 32768;
                  }
                ];
              };
            };
          };

          # Default agent model — points to native Google provider (uses GEMINI_API_KEY)
          agent = {
            default_model = {
              provider = "google";
              model = "gemini-3.1-pro-preview";
            };
            version = "2";
          };

          lsp = {
            nixd = {
              binary = {
                path = "${pkgs.nixd}/bin/nixd";
              };
              settings = {
                nixpkgs = {
                  expr = "import <nixpkgs> { }";
                };
                formatting = {
                  command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
                };

              };
            };
            rust-analyzer = {
              binary = {
                path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
              };
              initialization_options = {
                check = {
                  command = "clippy";
                };
              };
            };
            pyright = {
              binary = {
                path = "${pkgs.pyright}/bin/pyright-langserver";
                arguments = [ "--stdio" ];
              };
            };
            clangd = {
              binary = {
                path = "${pkgs.clang-tools}/bin/clangd";
                arguments = [
                  "--background-index"
                  "--clang-tidy"
                ];
              };
            };
          };

          languages = {
            Nix = {
              language_servers = [ "nixd" ];
              formatter = {
                external = {
                  command = "${pkgs.nixfmt}/bin/nixfmt";
                };
              };
            };
            Python = {
              language_servers = [ "pyright" ];
              formatter = {
                external = {
                  command = "${pkgs.ruff}/bin/ruff";
                  arguments = [
                    "format"
                    "-"
                  ];
                };
              };
            };
            Rust = {
              language_servers = [ "rust-analyzer" ];
            };
            "C++" = {
              language_servers = [ "clangd" ];
              formatter = {
                external = {
                  command = "${pkgs.clang-tools}/bin/clang-format";
                };
              };
            };
            C = {
              language_servers = [ "clangd" ];
              formatter = {
                external = {
                  command = "${pkgs.clang-tools}/bin/clang-format";
                };
              };
            };
          };
        };
      };
}
