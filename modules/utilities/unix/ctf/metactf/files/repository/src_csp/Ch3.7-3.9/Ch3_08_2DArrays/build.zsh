#!/bin/zsh
SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    RND=`echo $USER $SALT $BINNAME | openssl dgst -sha512 | awk '{print $2}' | tr -d abcdef`
    AA=`echo $RND | cut -c 1-5 | awk '{print $1%80+18}'`
    BB=`echo $RND | cut -c 6-10 | awk '{print $1%75+23}'`
    CC=`echo $RND | cut -c 11-15 | awk '{print $1%70+28}'`
    JUMPAA=$(((AA*15)+15))
    JUMPBB=$(((BB*20)+20))
    JUMPCC=$(((CC*25)+25))
    cat program.c.template | sed s/AAAAAA/$AA/g | sed s/BBBBBB/$BB/g | sed s/CCCCCC/$CC/g | sed s/JUMPAA/$JUMPAA/g | sed s/JUMPBB/$JUMPBB/g | sed s/JUMPCC/$JUMPCC/g >! program.c
    gcc -mno-align-double -o obj/$USER/$BINNAME program.c
  end
  rm program.c
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
