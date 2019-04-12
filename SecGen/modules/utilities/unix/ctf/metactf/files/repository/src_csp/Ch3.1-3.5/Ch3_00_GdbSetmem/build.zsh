#!/bin/zsh
SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    AA=`echo $USER $SALT $BINNAME | sha512sum | cut -c 1-8`
    BB=`echo $USER $SALT $BINNAME | sha512sum | cut -c 9-10`
    cat program.c.template | sed s/AAAAAA/0x$AA/ | sed s/BBBBBB/0x$BB/ >! program.c
    gcc -O0 -o obj/$USER/$BINNAME program.c
  end
  rm program.c
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
