#!/bin/zsh
SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    AA=`echo $USER $SALT $BINNAME | openssl dgst -sha512 -binary | sum | cut -c 1-3 | awk '{printf "%d", $1}'`
    cat program.c.template | sed s/AAAAAA/$AA/ >! program.c
    gcc -mno-align-double -o obj/$USER/$BINNAME program.c
    mv program.c obj/$USER/${BINNAME}.c
  end
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
