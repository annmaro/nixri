{ inputs, ... }:

let
  extensions = [
    "${inputs.thunderbird-catppuccin}/themes/mocha/mocha-mauve.xpi"
  ];
in
{
  programs.thunderbird = {
    enable = true;
    policies.Extensions.Install = extensions;
    settings = {
      "privacy.donottrackheader.enabled" = true;
    };
  };
}
