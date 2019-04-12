#!/bin/zsh

SALT=`date +%g`
if [[ ARGC -gt 0 ]] then
	BINNAME=`basename $PWD`
	foreach USER ($@)
		mkdir -p obj/$USER
		HASH=`echo $USER $SALT $BINNAME | sha256sum | awk '{print $1}' | cut -c 1-2 | tr \[a-f\] \[A-F\]`
		AA=`echo "ibase=16;$HASH" | bc`
		cat program.c.template | sed s/AAAAAA/$AA/ >! program.c
		gcc -m32 -Wformat=0 -o obj/$USER/$BINNAME program.c
	end
	rm program.c
else
	echo "USAGE: build.zsh <user_email(s)>"
fi
