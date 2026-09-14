{
  lib,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = [
    (_: {
      programs.zed-editor = {
        enable = true;

        extensions = [
          "nix"
          "toml"
          "rust"
          "python"
          "cpp"
          "qml"
          "catppuccin"
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
            };
          }
          {
            context = "Editor && vim_mode == insert";
            bindings = {
              # kj to exit insert mode
              "k j" = "vim::NormalBefore";
            };
          }
          {
            context = "Editor && vim_mode == visual";
            bindings = {
              # Keep visual selection while indenting
              "<" = "editor::Outdent";
              ">" = "editor::Indent";

              # Move lines up/down
              "shift-j" = "editor::MoveLineDown";
              "shift-k" = "editor::MoveLineUp";

              # Toggle comment on selection
              "space c" = "editor::ToggleComments";
            };
          }
        ];

        userSettings = {
          vim_mode = true;
          theme = {
            mode = "dark";
            dark = "Catppuccin Mocha";
            light = "Catppuccin Latte";
          };

          ui_font_size = 16;
          buffer_font_size = 15;
          relative_line_numbers = true;
          show_whitespaces = "selection";

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

          lsp = {
            nil = {
              binary = {
                path = "${pkgs.nil}/bin/nil";
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
              language_servers = [ "nil" ];
              formatter = {
                external = {
                  command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
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
    })
  ];
}
