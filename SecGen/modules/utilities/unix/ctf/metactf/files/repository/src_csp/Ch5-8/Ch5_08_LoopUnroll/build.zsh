#!/bin/zsh
SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    RND=`echo $USER $SALT $BINNAME | openssl dgst -sha512 | awk '{print $2}' | tr -d abcdef`
    AA=`echo $RND | cut -c 1 | awk '{print $1%5+5}'`
    BB=`echo $RND | cut -c 2 | awk '{print $1%5+5}'`
    CC=`echo $RND | cut -c 3 | awk '{print $1%5+5}'`
    DD=`echo $RND | cut -c 4 | awk '{print $1%5+5}'`
    EE=`echo $RND | cut -c 5 | awk '{print $1%5+5}'`
    FF=`echo $RND | cut -c 6 | awk '{print $1%5+5}'`
    GG=`echo $RND | cut -c 7 | awk '{print $1%5+5}'`
    HH=`echo $RND | cut -c 8 | awk '{print $1%5+5}'`
    XX=`echo $RND | cut -c 9 | awk '{print $1%3+2}'`
    YY=`echo $RND | cut -c 10 | awk '{print $1%3+5}'`
    ZZ=`echo $RND | cut -c 11 | awk '{print $1%2+8}'`
    cat program.c.template | sed s/AAAAAA/$AA/ | sed s/BBBBBB/$BB/ | sed s/CCCCCC/$CC/ | sed s/DDDDDD/$DD/ | sed s/EEEEEE/$EE/ | sed s/FFFFFF/$FF/ | sed s/GGGGGG/$GG/ | sed s/HHHHHH/$HH/ | sed s/XXXXXX/$XX/ | sed s/YYYYYY/$YY/ | sed s/ZZZZZZ/$ZZ/ >! program.c
    gcc -Og -o obj/$USER/$BINNAME program.c
  end
  rm program.c
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
