#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <wait.h>

int
main(int argc, char **argv)
{
  pid_t pid;
  int status;

  // used correctly?
  if(argc < 2) {
    fprintf(stderr, "Usage:\n\t%1$s <command>\nExamples:\n\t%1$s ls\n\t%1$s cat /etc/groups\n", argv[0]);
    exit(1);
  }

  // fork the process
  if((pid = fork()) < 0) {
    fprintf(stderr, "%s\n", strerror(errno));
    exit(1);
  } else if(pid == 0) {
    // execute the command given in the child
    if(execvp(argv[1], &argv[1]) < 0) {
      fprintf(stderr, "%s\n", strerror(errno));
      exit(1); // failed
    }
  } else {
    // wait for the child to finish
    while(wait(&status) != pid);
    exit(status); // return the status of the childe
  }
  
  return 0;
}
