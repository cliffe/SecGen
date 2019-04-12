#!/bin/zsh
# Start with a string of ASCII chars from 0x40-0x47, 0x50-0x57, 0x60-0x67, and
#  0x70-0x77.  XOR with character 0xAB, where A is 1-3, and B is 1-7.  This
#  keeps from generating confusing characters such as 0x7F
SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    AA=`echo $USER $SALT $BINNAME | openssl dgst -sha512 -binary | base64 | head -1 | tr -d 0123456789HIJKLMNOXYZhijklmnoxyz/=+ | cut -c 1-8`
    B1=`echo $USER $SALT $BINNAME B1 | openssl dgst -sha512 -binary | sum  | awk '{print ($1 % 3)+1}'`
    B2=`echo $USER $SALT $BINNAME B2 | openssl dgst -sha512 -binary | sum  | awk '{print ($1 % 7)+1}'`
    cat program.c.template | sed s/AAAAAA/$AA/ | sed s/BBBBBB/0x$B1$B2/ >! program.c
    gcc -o obj/$USER/$BINNAME program.c
  end
  rm program.c
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
