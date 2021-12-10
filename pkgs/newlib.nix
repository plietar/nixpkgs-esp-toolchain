{ sources
, target
, target-gcc
, target-binutils
, target-cflags ? [ ]
, xtensa-dynconfig ? null
, stdenv
, fetchFromGitHub
, lib
, texinfo
}:
stdenv.mkDerivation {
  pname = "${target}-newlib";
  inherit (sources.newlib-esp32) version;
  src = fetchFromGitHub {
    inherit (sources.newlib-esp32) owner repo rev hash;
  };

  CFLAGS_FOR_TARGET = lib.concatStringsSep " " (target-cflags ++ [ "-fdata-sections" "-ffunction-sections" ]);
  CXXFLAGS_FOR_TARGET = lib.concatStringsSep " " (target-cflags ++ [ "-fdata-sections" "-ffunction-sections" ]);

  configureFlags = [
    "--target=${target}"
    "--enable-multilib"
    "--enable-newlib-long-time_t"
    "--enable-newlib-nano-malloc"
    "--enable-newlib-retargetable-locking"
    "--enable-newlib-iconv"
    "--enable-newlib-io-long-long"
    "--enable-newlib-io-float"
    "--enable-newlib-reent-small"
  ];
  buildInputs = [
    target-gcc
    target-binutils
    texinfo
  ];

  XTENSA_GNU_CONFIG = xtensa-dynconfig;
}
