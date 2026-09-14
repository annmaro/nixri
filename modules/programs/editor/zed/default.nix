{
  lib,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = [
    (_: {
      # Optional: set Vulkan software fallback if ever running on a headless or VM setup
      # home.sessionVariables.LIBGL_ALWAYS_SOFTWARE = "0";

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
            context = "VimControl && !menu";
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

              # Diagnostics
              "[ d" = "editor::GoToPrevDiagnostic";
              "] d" = "editor::GoToNextDiagnostic";
              "g h" = "editor::Hover";

              # Sidebar toggle
              "ctrl-n" = "workspace::ToggleLeftDock";
            };
          }
          {
            context = "VimControl && vim_mode == insert";
            bindings = {
              # kj to exit insert mode
              "k j" = "vim::NormalBefore";
            };
          }
          {
            context = "VimControl && vim_mode == visual";
            bindings = {
              # Stay in visual mode while indenting
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
          # buffer_font_size = 15;
          relative_line_numbers = true;
          format_on_save = "on";
          show_whitespaces = "selection";

          telemetry = {
            diagnostics = false;
            metrics = false;
          };

          inlay_hints = {
            enabled = true;
            show_type_hints = true;
            show_parameter_hints = true;
          };

          # Explicitly bound to system packages to bypass NixOS glibc issues
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
    })
  ];
}
