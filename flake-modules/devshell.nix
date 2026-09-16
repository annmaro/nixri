{ ... }:

{
  perSystem = { pkgs, ... }: {
    devShells = {
      rust = pkgs.mkShell {
        name = "rust-devshell";

        packages = with pkgs; [
          cargo
          clippy
          rust-analyzer
          rustc
          rustfmt
        ];
      };

      python = pkgs.mkShell {
        name = "python-devshell";

        packages = with pkgs; [
          (python3.withPackages (pythonPackages: with pythonPackages; [
            pip
            setuptools
            wheel
          ]))
          pyright
          ruff
          uv
        ];
      };
    };
  };
}
