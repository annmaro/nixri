{ config, pkgs, ... }:

let
  stylixColors = config.lib.stylix.colors or { };

  labels = "#${stylixColors.base0E or "cba6f7"}";
  kernelCol = "#${stylixColors.base0D or "89b4fa"}";
  uptimeCol = "#${stylixColors.base0B or "a6e3a1"}";
  pkgsCol = "#${stylixColors.base08 or "f38ba8"}";
  shellCol = "#${stylixColors.base0A or "f9e2af"}";
  cpuCol = "#${stylixColors.base0C or "89dceb"}";
  gpuCol = "#${stylixColors.base0C or "89dceb"}";
  memCol = "#${stylixColors.base0F or "f5c2e7"}";
  wmCol = "#${stylixColors.base09 or "fab387"}";
  termCol = "#${stylixColors.base07 or "b4befe"}";
in
{
  programs.fastfetch = {
    enable = true;
    package = pkgs.fastfetch;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      logo = {
        source = ../../data/terminal/nixos-logo.png;
        type = "sixel";
      };

      display = {
        separator = " ── ";
        color = {
          keys = labels;
          title = "#${stylixColors.base05 or "cdd6f4"}";
        };
      };

      modules = [
        {
          type = "title";
          color = {
            user = labels;
            host = memCol;
          };
        }
        "break"
        {
          type = "os";
          key = "󱄅 os";
          keyColor = labels;
        }
        {
          type = "kernel";
          key = "󰌽 kernel";
          keyColor = kernelCol;
        }
        {
          type = "uptime";
          key = "󱎫 uptime";
          keyColor = uptimeCol;
        }
        {
          type = "packages";
          key = "󰏖 packages";
          keyColor = pkgsCol;
        }
        {
          type = "shell";
          key = "󱆃 shell";
          keyColor = shellCol;
        }
        "break"
        {
          type = "cpu";
          key = "󰻠 cpu";
          keyColor = cpuCol;
        }
        {
          type = "gpu";
          key = "󰢮 gpu";
          keyColor = gpuCol;
        }
        {
          type = "memory";
          key = "󰍛 memory";
          keyColor = memCol;
        }
        {
          type = "wm";
          key = " wm";
          keyColor = wmCol;
        }
        {
          type = "terminal";
          key = " terminal";
          keyColor = termCol;
        }
        "break"
        {
          type = "colors";
          symbol = "circle";
          paddingLeft = 2;
        }
      ];
    };
  };
}
