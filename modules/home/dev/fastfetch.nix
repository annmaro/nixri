{ config, pkgs, ... }:

let
  stylixColors = config.lib.stylix.colors or { };

  labels = "#${stylixColors.base0E or "d3869b"}";
  kernelCol = "#${stylixColors.base0D or "7daea3"}";
  uptimeCol = "#${stylixColors.base0B or "a9b665"}";
  pkgsCol = "#${stylixColors.base08 or "ea6962"}";
  shellCol = "#${stylixColors.base0A or "d8a657"}";
  cpuCol = "#${stylixColors.base0C or "89b482"}";
  gpuCol = "#${stylixColors.base0C or "89b482"}";
  memCol = "#${stylixColors.base0F or "bd6f3e"}";
  wmCol = "#${stylixColors.base09 or "e78a4e"}";
  termCol = "#${stylixColors.base07 or "fbf1c7"}";
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
          title = "#${stylixColors.base05 or "ddc7a1"}";
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
