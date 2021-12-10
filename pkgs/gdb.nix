{ target
, lib
, stdenv
, gmp
, fetchFromGitHub
, texinfo
, bison
, perl
, zlib
, gettext
, flex
}:
stdenv.mkDerivation {
  pname = "${target}-gdb";
  version = "12.1";

  src = fetchFromGitHub {
    owner = "espressif";
    repo = "binutils-gdb";
    rev = "esp-gdb-v12.1_20231023";
    fetchSubmodules = true;
    hash = "sha256-e/DBMuPaBNAQDxkDuO4p1LcosU4pLH8cDHByWD/yUXs=";
  };

  # preConfigure = ''
  #   ls
  #   pushd xtensaconfig
  #   TARGET_ESP_ARCH=xtensa DESTDIR=$out PLATFORM=macos make install
  #   popd
  # '';

  configureFlags = [
    "--target=${target}"
    "--program-prefix=${target}-"
    "--disable-werror"
    "--with-system-zlib"
    "--disable-binutils"
    "--disable-sim"
    #"--with-xtensaconfig"
  ];

  nativeBuildInputs = [
    texinfo
    flex
    bison
    perl
  ];
  buildInputs = [ zlib gettext gmp ];

  # darwin build fails with format hardening since v7.12
  hardeningDisable = lib.optionals stdenv.isDarwin [ "format" ];

  # https://sourceware.org/git/?p=binutils-gdb.git;h=ae61525fcf456ab395d55c45492a106d1275873a
  env.NIX_CFLAGS_COMPILE = "-Wno-enum-constexpr-conversion";
}
