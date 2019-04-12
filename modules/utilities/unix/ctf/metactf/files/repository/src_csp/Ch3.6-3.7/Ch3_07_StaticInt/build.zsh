#!/bin/zsh
# Take subset of SHA, convert to decimal in bc
SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    HASH=`echo $USER $SALT $BINNAME | openssl dgst -sha512 | awk '{print $2}' | cut -c 1-9 | tr \[a-f\] \[A-F\]`
    AA=${HASH:1:4}
    A=`echo "ibase=16;$AA" | bc`
    BB=${HASH:5:8}
    B=`echo "ibase=16;$BB" | bc`
    cat program.c.template | sed s/AAAAAA/$A/ | sed s/BBBBBB/$B/ >! program.c
    gcc -o obj/$USER/$BINNAME program.c
  end
  rm program.c
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
