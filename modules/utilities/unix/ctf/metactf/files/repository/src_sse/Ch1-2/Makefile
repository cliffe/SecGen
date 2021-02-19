SUBDIRS = $(wildcard Ch*_*)
export WWWDIR=../www/static/obj
export USERS=$(shell cut -d" " -f 1 ../users)
export CURDIR=$(notdir ${PWD})

all:
	$(foreach dir,$(SUBDIRS),cd $(dir); ./build.zsh $(USERS); cd ..;)

clean:
	$(foreach dir,$(SUBDIRS),cd $(dir); \rm -rf obj; cd ..;)

install:
	$(foreach dir,$(SUBDIRS),$(foreach user,$(USERS),[ -f $(dir)/obj/$(user)/$(dir) ] && (mkdir -p $(WWWDIR)/$(user)/$(CURDIR)/solved; mv $(dir)/obj/$(user)/* $(WWWDIR)/$(user)/$(CURDIR)) || true;))
