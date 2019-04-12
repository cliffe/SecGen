#!/bin/zsh
SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    AA=`echo $USER $SALT $BINNAME | sha512sum | sum | cut -c 1-8 | awk '{printf "%f",$1}'`
    cat program.c.template | sed s/AAAAAA/$AA/ >! program.c
    gcc -mno-align-double -o obj/$USER/$BINNAME program.c
    #mv program.c obj/$USER/${BINNAME}.c
    rm program.c
  end
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
