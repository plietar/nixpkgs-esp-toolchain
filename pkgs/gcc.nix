{ sources
, target
, target-binutils
, target-newlib ? null
, target-cflags ? [ ]
, langC ? true
, langCC ? true
, xtensa-dynconfig ? null
, lib
, stdenv
, fetchFromGitHub
, texinfo
, bison
, perl
, zlib
, gettext
, gmp
, mpfr
, libmpc
, isl
, flex
}:
let
  suffix = if target-newlib == null then "-static" else "";
  enable-languages = lib.concatStringsSep "," (lib.optional langC "c" ++ lib.optional langCC "c++");
  build-targets =
    [ "gcc" ]
    ++ lib.optional (target-newlib != null) "target-libgcc"
    ++ lib.optional langCC "target-libstdc++-v3";
in
stdenv.mkDerivation {
  pname = "${target}-gcc${suffix}";
  inherit (sources.gcc) version;

  src = fetchFromGitHub {
    inherit (sources.gcc) owner repo rev hash;
  };

  preConfigure = ''
    mkdir ../build
    cd ../build

    configureScript=../$sourceRoot/configure

    # esp-idf expects this string and will reject anything that doesn't match.
    configureFlagsArray+=("--with-pkgversion=crosstool-NG ${sources.gcc.rev}")
  '';

  configureFlags = [
    "--target=${target}"
    "--program-prefix=${target}-"
    "--disable-werror"
    "--with-system-zlib"
    "--with-newlib"
    "--with-as=${target-binutils}/bin/${target}-as"
    "--with-ld=${target-binutils}/bin/${target}-ld"
    "--enable-languages=${enable-languages}"
    "--enable-multilib"
    "--enable-static"
    "--disable-decimal-float"
    "--disable-libatomic"
    "--disable-libgomp"
    "--disable-libmpx"
    "--disable-libquadmath"
    "--disable-libssp"
    "--disable-nls"
    "--disable-shared"
    "--disable-threads"
    "--enable-libstdcxx-time"
    "--disable-__cxa_atexit"
  ]
  ++ lib.optionals (target == "riscv32-esp-elf") [
    "--with-arch=rv32gc"
    "--with-abi=ilp32"
  ]
  ++ (if target-newlib == null then [
    "--without-headers"
  ] else [
    "--with-headers=${target-newlib}/${target}/include"
  ]);

  CFLAGS_FOR_TARGET = target-cflags;
  CXXFLAGS_FOR_TARGET = target-cflags;

  nativeBuildInputs = [
    texinfo
    bison
    perl
    flex
  ];

  propagatedNativeBuildInputs = [
    target-binutils
  ];

  postInstall = lib.optionalString (target-newlib != null) ''
    cp -rv ${target-newlib}/${target}/. $out/${target}
  '';

  buildInputs = [ zlib gettext gmp mpfr libmpc isl ];
  hardeningDisable = [ "format" ];

  makeFlags = map (t: "all-${t}") build-targets;
  installTargets = map (t: "install-${t}") build-targets;

  XTENSA_GNU_CONFIG = xtensa-dynconfig;

  dontStrip = true;
}
