#!/bin/zsh

SALT=`date +%N`
if [[ ARGC -gt 0 ]] then
	BINNAME=`basename $PWD`
	foreach USER ($@)
		mkdir -p obj/$USER
		HASH=`echo $USER $SALT $BINNAME | openssl dgst -sha512 -binary | base64 | head -1 | tr -d /=+ | cut -c 1-2 | xxd -p | sed s/0a$/407a/`
		AA=6${HASH:1:8}
		cat program.c.template >! program.c
		gcc -m32 -Wformat=0 -Wno-stack-protector -Wl,--section-start=.text=0x$AA -o obj/$USER/$BINNAME program.c
	end
	rm program.c
else
	echo "USAGE: build.zsh <user_email(s)>"
fi
