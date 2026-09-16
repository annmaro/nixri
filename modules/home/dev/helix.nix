{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    helix
    # Language Servers, Linters & Formatters
    nil
    # Nix LSP
    nixfmt # Nix formatter
    rust-analyzer # Rust LSP
    rustfmt # Rust formatter
    clippy # Rust linter
    pyright # Python LSP
    ruff # Python linter & formatter
    clang-tools # C/C++ clangd & clang-format
    lldb # Debugger
  ];

  programs.helix = lib.mkIf (config.homeSettings.editor == "hx") {
    enable = true;
    defaultEditor = true;

    settings = {

      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        bufferline = "multiple";
        auto-format = true;
        completion-replace = true;
        mouse = true;

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        indent-guides = {
          render = true;
          character = "│";
        };
      };

      keys = {
        normal = {
          # Fast buffer switching (matching <S-h> and <S-l>)
          "H" = ":buffer-previous";
          "L" = ":buffer-next";

          # Window / Split navigations
          "C-h" = "jump_view_left";
          "C-j" = "jump_view_down";
          "C-k" = "jump_view_up";
          "C-l" = "jump_view_right";

          # Diagnostics navigation
          "[" = {
            "d" = "goto_prev_diag";
          };
          "]" = {
            "d" = "goto_next_diag";
          };

          # Space-prefixed custom workflow shortcuts
          space = {
            "w" = ":w";
            "q" = ":q";
            "x" = ":bc"; # close current buffer
            "v" = "vsplit";
            "s" = "hsplit";
            "f" = "file_picker";
            "p" = ":format";
            "c" = {
              "a" = "code_action";
            };
          };
        };

        insert = {
          # kj to exit insert mode
          "k" = {
            "j" = "normal_mode";
          };
        };
      };
    };

    languages = {
      language-server.nil = {
        command = "${pkgs.nil}/bin/nil";
        config.nil.formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
      };

      language-server.pyright = {
        command = "${pkgs.pyright}/bin/pyright-langserver";
        args = [ "--stdio" ];
      };

      language-server.ruff = {
        command = "${pkgs.ruff}/bin/ruff";
        args = [ "server" ];
      };

      language-server.rust-analyzer = {
        command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        config.rust-analyzer = {
          checkOnSave.command = "clippy";
          cargo.allFeatures = true;
          inlayHints.lifetimeElisionHints.enable = "always";
        };
      };

      language-server.clangd = {
        command = "${pkgs.clang-tools}/bin/clangd";
        args = [
          "--background-index"
          "--clang-tidy"
          "--completion-style=detailed"
          "--header-insertion=iwyu"
        ];
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          language-servers = [ "nil" ];
          formatter = {
            command = "${pkgs.nixfmt}/bin/nixfmt";
          };
        }
        {
          name = "python";
          auto-format = true;
          language-servers = [
            "pyright"
            "ruff"
          ];
          formatter = {
            command = "${pkgs.ruff}/bin/ruff";
            args = [
              "format"
              "-"
            ];
          };
        }
        {
          name = "rust";
          auto-format = true;
          language-servers = [ "rust-analyzer" ];
        }
        {
          name = "c";
          auto-format = true;
          language-servers = [ "clangd" ];
          formatter = {
            command = "${pkgs.clang-tools}/bin/clang-format";
          };
        }
        {
          name = "cpp";
          auto-format = true;
          language-servers = [ "clangd" ];
          formatter = {
            command = "${pkgs.clang-tools}/bin/clang-format";
          };
        }
      ];
    };
  };
}
