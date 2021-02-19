#!/bin/zsh

SALT=`date +%N`
if [[ ARGC -gt 0 ]] then
	BINNAME=`basename $PWD`
	foreach USER ($@)
		mkdir -p obj/$USER
		HASH=`echo $USER $SALT $BINNAME | sha256sum | awk '{print $1}' | cut -c 1-2 | tr \[a-f\] \[A-F\] | sed 's/[012]$/3/'`
		# AA=`echo "ibase=16;$HASH*100" | bc`
		# Keep text segment above 40000
		AA=4${HASH}00
		cat program.c.template >! program.c
		gcc -m32 -Wformat=0 -Wno-stack-protector -Wl,--section-start=.text=0x${AA} -o obj/$USER/$BINNAME program.c
	end
	rm program.c
else
	echo "USAGE: build.zsh <user_email(s)>"
fi
