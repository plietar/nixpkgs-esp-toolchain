{ runCommand, makeWrapper, xtensa-dynconfig }:
name: unwrapped: runCommand name
{
  buildInputs = [ makeWrapper ];
  CHIPS = [ "esp32" "esp32s2" "esp32s3" ];
} ''
  mkdir -p $out/bin
  for chip in $CHIPS; do
    for tool in $(find ${unwrapped}/bin -type f); do
      name=$(basename $tool)
      if [[ $name =~ ^xtensa-esp-elf-(cc|gcc|g\+\+|c\+\+|gcc-[0-9.]+)$ ]]; then
        makeWrapper $tool $out/bin/''${name//esp/$chip} --set XTENSA_GNU_CONFIG ${xtensa-dynconfig}/lib/xtensa_esp32.so
      else
        makeWrapper $tool $out/bin/''${name//esp/$chip} --set XTENSA_GNU_CONFIG ${xtensa-dynconfig}/lib/xtensa_esp32.so
      fi
    done
  done
''
