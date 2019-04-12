CC=gcc
#CCFLAGS=-g3 -Wall -w -pedantic -fmessage-length=0 -fno-stack-protector -D_FORTIFY_SOURCE=0 -pie -fPIE
#CCFLAGS=-O3
#CCFLAGS=-g3 -Wall -w -pedantic -fmessage-length=0 
CCFLAGS=-g3 -Wall -w -pedantic -fmessage-length=0 -m32
#CCFLAGS=-g3 -Wall -w -pedantic -fmessage-length=0 -fno-stack-protector -fPIC

O_FILES = main.o

feedme: $(O_FILES)
	$(CC) $(CCFLAGS) -o feedme $(O_FILES)

# dependency stuff, see: http://www.cs.berkeley.edu/~smcpeak/autodepend/autodepend.html
# pull in dependency info for *existing* .o files
-include $(O_FILES:.o=.d)

.SUFFIXES : .o .c

.c.o :  
	$(CC) $(CCFLAGS) -c $<
	$(CC) -MM $(CFLAGS) $*.c > $*.d

clean:
	rm -f feedme *.o *.d
