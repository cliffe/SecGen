#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <signal.h>
#include <stdlib.h>

char msg[] =
 "Memory corruption bugs are often used to overwrite function pointers,\n"
 "allowing the attacker to gain control of program execution.  In this level,\n"
 "unlock the program by finding the virtual address of the function you want\n"
 "to call and entering it as the password (in hexadecimal). Be careful,\n"
 "incorrect addresses often result in illegal instruction exceptions and\n"
 "segmentation faults (which we have conveniently handled for you).\n\n";

typedef void (*fnp)(void);

void segv_handler(int sig) {
  printf("Segmentation fault.  Try again\n");
  exit(0);
}
void ill_handler(int sig) {
  printf("Illegal instruction hit.  Try again\n");
  exit(0);
}
/* Symbolic execution trap */
void print_msg() {
  unsigned int i,h1,h2;
  unsigned int len=strlen(msg);
  for (i = 0; i < 100*len; i++) {
    h1 += msg[i%len] + msg[(i+1)%len];
    h2 += msg[(i+1)%len] + msg[(i+2)%len];
  }
  if (h1 == h2)
    printf("%s",msg);
  else
    printf("%s",msg);
}

void printflag()
{
	int fd;
	int len;
	unsigned char data[128];

	fd = open("flag", O_RDONLY);

	if ( fd <= 0 ) {
		printf("Failed to open flag.\n");
		return;
	}

	len = lseek( fd, 0, SEEK_END);
	lseek(fd, 0, SEEK_SET);

	if ( len > 128 ) {
		len = 128;
	}

	memset(data, 0, 128);
	read( fd, data, len);
	close(fd);

	printf("%s\n", data);
	return;
}

int main()
{
  unsigned long int x;
  fnp f;
  signal(SIGSEGV, segv_handler);
  signal(SIGILL, ill_handler);

  print_msg();

  printf("Enter the password: ");
  scanf("%lx", &x);
  f = (fnp) x;
  //printf("Calling the function at %x\n",f);
  f();
  exit(0);
}

void print_good() {
  printf("Good Job.\n");
  printflag();
  exit(0);
}

void print_nogood() {
  printf("Try again.\n");
}
