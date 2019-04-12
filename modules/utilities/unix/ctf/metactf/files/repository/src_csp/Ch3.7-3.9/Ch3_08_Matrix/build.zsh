#!/bin/zsh
SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    AA=`echo $USER $SALT $BINNAME | sha512sum | sum | cut -c 1 | awk '{printf "%d",$1+50}'`
    BB=`echo $USER $SALT $BINNAME | sha512sum | sum | cut -c 2 | awk '{printf "%d",$1+8}'`
    CC=`echo $USER $SALT $BINNAME | sha512sum | sum | cut -c 3 | awk '{printf "%d",$1+10}'`
    DD=`echo $USER $SALT $BINNAME | sha512sum | sum | cut -c 4-5 | awk '{printf "%d",$1+40}'`
    cat program.c.template | sed s/AAAAAA/$AA/ | sed s/BBBBBB/$BB/ | sed s/CCCCCC/$CC/ | sed s/DDDDDD/$DD/ >! program.c
    gcc -o obj/$USER/$BINNAME program.c
    rm program.c
  end
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
