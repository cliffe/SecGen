#!/bin/zsh
SALT=`date +%N`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    AA=`echo $USER $SALT $BINNAME | sha512sum | base64 | head -1 | cut -c 1-8`
    cat program.c.template | sed s/AAAAAA/$AA/ >! program.c
    gcc -o obj/$USER/$BINNAME program.c
  end
  rm program.c
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
