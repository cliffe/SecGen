#!/bin/zsh
SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    AA=`echo $USER $SALT $BINNAME AA | openssl dgst -sha512 -binary | sum | awk '{printf "%d",$1}'`
    BB=`echo $USER $SALT $BINNAME BB | openssl dgst -sha512 -binary | sum | awk '{printf "%d",$1}'`
    cat program.c.template | sed s/AAAAAA/$AA/ | sed s/BBBBBB/$BB/>! program.c
    gcc -o obj/$USER/$BINNAME program.c
  end
  rm program.c
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
