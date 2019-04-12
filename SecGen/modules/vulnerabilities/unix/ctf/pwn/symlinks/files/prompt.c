#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

int
main(int argc, char **argv)
{
  FILE *f;
  char b[BUFSIZ], c[BUFSIZ];
  struct stat s;

  // called correctly?
  if(argc != 2) {
    fprintf(stderr, "Usage: %s <file>\n", argv[0]);
    exit(1);
  }

  // get the stat info for the file
  if(stat(argv[1], &s) != 0) {
    puts(strerror(errno));
    exit(2);
  }

  // are 'others' allowed to read it?
  if((s.st_mode & S_IROTH) != S_IROTH) {
    puts(strerror(EPERM));
    exit(3);
  }

  // so far so good ...
  fputs("The file is accessible by all. Press ENTER to print its contents.", stdout);
  do {
    // read in a line from the command line
    if(fgets(c, BUFSIZ, stdin) == NULL) {
      if(feof(stdin)) { // stdin closed?
        break;
      } else {
        // we have a problem
        puts(strerror(errno));
        exit(4);
      }
    }

    // remove final enter
    c[strlen(c) - 1] = '\0';
    if(strlen(c) == 0) { // an enter will have zero characters
      // open the file
      if((f = fopen(argv[1], "r"))  == NULL) {
        puts(strerror(errno));
        exit(4);
      }

      // read the entire file
      while(fgets(b, BUFSIZ, f) != NULL) {
        fputs(b, stdout); // print to console
      }

      // did we end cleanly?
      if(feof(f)) {
        fclose(f);
      } else {
        // no we did not.
        puts(strerror(errno));
        exit(5);
      }

      break;
    } else {
      // round again
      fputs("Press ENTER to print its contents.", stdout);
    }
  // we can quit if we like.
  } while(strncmp(c, "quit", 5) != 0);

  return 0;
}
