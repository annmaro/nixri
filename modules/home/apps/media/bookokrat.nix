{ inputs, ... }:

{
  home.packages = [
    inputs.bookokrat.packages.x86_64-linux.default
  ];
}
