#!/bin/zsh
SALT=`date +%N`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    AA=`echo $USER $SALT $BINNAME | openssl dgst -sha512 -binary | base64 | head -1 | tr -d /=+ | cut -c 1-3 | xxd -p | sed s/0a$/7a/`
    gcc -Wl,--section-start=.text=0x$AA -o obj/$USER/$BINNAME program.c
    cp program.c obj/$USER/${BINNAME}.c
  end
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
