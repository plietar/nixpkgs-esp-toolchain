{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages."${system}";
          versions = [
            "20230208"
            "20230928"
            "20240109"
          ];

          xtensa-dynconfig = pkgs.callPackage ./pkgs/xtensa-dynconfig.nix { };
          wrapXtensaToolchain = pkgs.callPackage ./pkgs/xtensa-make-wrapper.nix {
            inherit xtensa-dynconfig;
          };

          makeToolchain = version:
            let
              sources = nixpkgs.lib.importJSON (./versions + "/${version}.json");
              riscv32-esp = pkgs.callPackage ./pkgs/toolchain.nix {
                inherit sources;
                target = "riscv32-esp-elf";
              };
              xtensa-esp = pkgs.callPackage ./pkgs/toolchain.nix {
                inherit sources xtensa-dynconfig;
                target = "xtensa-esp-elf";
                target-cflags = [ "-mlongjumps" ];
              };
            in
            {
              "riscv32-esp-binutils-${version}" = riscv32-esp.binutils;
              "riscv32-esp-gcc-${version}" = riscv32-esp.gcc;
              "riscv32-esp-gdb-${version}" = riscv32-esp.gdb;
              "xtensa-esp-binutils-${version}" = wrapXtensaToolchain "xtensa-esp-binutils" xtensa-esp.binutils;
              "xtensa-esp-gcc-${version}" = wrapXtensaToolchain "xtensa-esp-gcc" xtensa-esp.gcc;
            };
        in
        {
          packages = nixpkgs.lib.attrsets.mergeAttrsList (map makeToolchain versions);
          apps.update = {
            type = "app";
            program = builtins.toString (pkgs.writeShellScript "update" ''
              exec ${pkgs.python311}/bin/python3 ${./update.py} "$@"
            '');
          };
        });
}
