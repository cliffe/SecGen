# Unused dirs: Beta Extra-FormatStr
SUBDIRS = Ch1-2 Ch3.1-3.5 Ch3.6-3.7 Ch3.7-3.9 Ch5-8
# Ch3-ExtraFormatStr

export WWWDIR_OBJ=$(PWD)/www/static/obj
export WWWDIR_LOG=$(PWD)/www/static/logs
export USERS=$(shell cut -d" " -f 1 users)

.PHONY : all wwwusers $(SUBDIRS) install clean distclean

all:
	$(foreach dir,$(SUBDIRS),cd $(dir) && $(MAKE) && cd ..;)

wwwusers:
	python3 wwwusers.py

$(SUBDIRS):
	cd $@ && $(MAKE)

install: wwwusers
	$(foreach dir,$(SUBDIRS),cd $(dir) && $(MAKE) install && cd ..;)
	echo "Reloading systemd services for new accounts to load"
	sudo systemctl daemon-reload

clean:
	$(foreach dir,$(SUBDIRS),cd $(dir) && $(MAKE) clean && cd ..;)

distclean: clean
	rm -rf $(WWWDIR_OBJ);
	rm -rf $(WWWDIR_LOG);
