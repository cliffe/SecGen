#!/bin/zsh
SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
  BINNAME=`basename $PWD`
  foreach USER ($@)
    mkdir -p obj/$USER
    HASH=`echo $USER $SALT $BINNAME | openssl dgst -sha512 -binary | base64 | head -1 | tr -d /=+ | cut -c 1-9`
    AA=$HASH[1]
    BB=$HASH[2]
    CC=$HASH[3]
    DD=$HASH[4]
    EE=$HASH[5]
    FF=$HASH[6]
    GG=$HASH[7]
    HH=$HASH[8]
    cat program.c.template | sed s/AAAAAA/$AA/ | sed s/BBBBBB/$BB/ | sed s/CCCCCC/$CC/ | sed s/DDDDDD/$DD/ | sed s/EEEEEE/$EE/ | sed s/FFFFFF/$FF/ | sed s/GGGGGG/$GG/ | sed s/HHHHHH/$HH/ >! program.c
    gcc -o obj/$USER/$BINNAME program.c
  end
  rm program.c
else
  echo "USAGE: build.zsh <user_email(s)>"
fi
