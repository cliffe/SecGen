#!/bin/zsh
SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    AA=`echo $USER $SALT $BINNAME | sha512sum | cut -c 1-2`
    BB=`echo $USER $SALT $BINNAME | sha512sum | cut -c 3-6`
    CC=`echo $USER $SALT $BINNAME | sha512sum | cut -c 7-14`
    cat program.c.template | sed s/AAAAAA/0x$AA/ | sed s/BBBBBB/0x$BB/ | sed s/CCCCCC/0x$CC/ >! program.c
    gcc -o obj/$USER/$BINNAME program.c
    rm program.c
  end
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
