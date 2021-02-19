#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>

void printflag();

char msg[] =
 "One way attackers used to leverage buffer overflow bugs to gain control of\n"
 "a running program is to overwrite the return address of the function being\n"
 "executed on the stack.  When the function returns, it returns to an address\n"
 "the attacker chooses.  In this level, you are to overflow the buffer being\n"
 "used to read in the password in a way that overwrites the return address of\n"
 "the function it is in (unsafe_input).  A quick strategy to determine the\n"
 "size of the unsafe buffer is to \"fuzz\" the program with a large sequence\n"
 "of characters such as (AABBCCDDEEFFGG...) and see which ones appear during\n"
 "critical execution points such as the return from unsafe_input. To simplify\n"
 "the task of corrupting the return address, the location of the call you want\n"
 "to return to that unlocks the program is in the ASCII range.  Be mindful of\n"
 "endianness and ensure that you only overwrite the low 32-bits to point to\n"
 "the function you want to return to.\n\n";

void print_good() {
	printf("Good Job.\n");
    printflag();
    exit(0);
}
void segv_handler(int sig) {
        printf("Segmentation fault.  Try again.\n");
        exit(0);
}
void unsafe_input() {
    char buf[16];
    printf("Enter the password: ");
    scanf("%s",buf);
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
int main () {
    signal(SIGSEGV, segv_handler);
    print_msg();
    unsafe_input();
    printf("Try again.\n");
    return 0;
}
