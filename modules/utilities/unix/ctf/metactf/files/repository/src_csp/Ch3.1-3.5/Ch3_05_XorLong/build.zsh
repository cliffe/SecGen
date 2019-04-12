#!/bin/zsh
# Start with a decimal string.  XOR with slightly random byte to ensure 
# 0x7f is never generated
SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    ZZ=`echo $USER $SALT $BINNAME | openssl dgst -sha512 | awk '{print $2}' | tr \[a-f\] \[A-F\]`
    AA=${ZZ:1:16}
    BB=${ZZ:17:2}
    cat program.c.template | sed s/AAAAAA/0x$AA/ | sed s/BBBBBB/0x$BB/ >! program.c
    gcc -o obj/$USER/$BINNAME program.c
  end
  rm program.c
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
