WWWDIR=$(PWD)/www/static/obj
USERS=$(shell cut -d" " -f 1 users)

.PHONY: all wwwusers install clean distclean

all:
	$(foreach user,$(USERS),python2 package.py obj/$(user)/angr;)

wwwusers:
	python3 wwwusers.py

install: wwwusers
	mkdir -p $(WWWDIR) && cp -R obj/* $(WWWDIR)

clean:
	rm -rf obj

distclean:
	rm -rf $(WWWDIR)
