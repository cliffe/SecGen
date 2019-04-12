/* Generic setuid/setgid wrapper for scripts.
*
* Copyright (c) 2016  Likai Liu <liulk@likai.org>
*
* Usage of the works is permitted provided that this instrument is
* retained with the works, so that any entity that uses the works is
* notified of this instrument.
* DISCLAIMER: THE WORKS ARE WITHOUT WARRANTY.
*/

/*
* Usage: use the following shebang line in the script.
*   #!/usr/local/bin/suid /path/to/interpreter [options] --
*
* Mac OS X ignores the setuid of the first interpreter, so we reexec
* ourselves to get it back.  Linux will pass /path/to/interpreter and
* all the options to us as one argument, but we will split them by
* whitespaces only (no quotes).
*
* Interpreter options must be given before the "--" marker which is
* mandatory.  The implicit last argument is the script itself, which
* must also have the executable bit set as well as setuid or setgid.
*
* For shell scripts, it is necessary to pass -p or -o privileged to
* /bin/bash in the shebang line, or it will reset the effective uid
* and gid to the real ones.  Other options are strongly recommended
* to be set explicitly in the script, e.g. "set -eu".
*
* A setuid binary has getuid() set to the invoking user, and
* geteuid() set to the owner of the binary.  This wrapper will keep
* the same getuid() and getgid() but further modify geteuid() and
* geteguid() to the owner of the script, according to the setuid and
* setgid bits of the script itself.  In order for this to work, the
* wrapper binary itself must be setuid root or the script owner.
*
* Here are the safety measures we take:
*
*   - All LD_* and DYLD_* environment variables are cleared.
*   - The script name is replaced with /dev/fd/NN.
*
* The script is responsible for ensuring sane IFS and PATH.  Note
* that on bash, IFS changes the way variables are expanded when it
* appears on a command line, but hard-coded text remains unaffected.
*
* Further reading:
*   http://www.dwheeler.com/secure-programs/Secure-Programs-HOWTO/avoid-setuid.html
*   http://profesores.elo.utfsm.cl/~agv/elo330/programs/shell/NotUseSetuidScripts.html
*   http://burrows.svbtle.com/bash-privileged-mode-quirk
*/

#include <ctype.h>
  #include <fcntl.h>
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <sys/stat.h>
  #include <sysexits.h>
  #include <unistd.h>

  static const char usage[] =
  "Usage: use the following shebang line in the script.\n"
  "  #!/path/to/suid /path/to/interpreter [options] --\n";

  extern char **environ;

  static void sanitize_environ(char **environ) {
  int in, out;
  for (in = 0, out = 0; environ[in] != NULL; ++in) {
  if (strncmp(environ[in], "LD_", 3) == 0 ||
  strncmp(environ[in], "DYLD_", 5) == 0)
  continue;  /* skip */
  environ[out++] = environ[in];  /* keep */
  }
  environ[out] = NULL;  /* terminate list */
  }

  /* always returns the true next powers of 2; e.g. next_pow2(8) returns 16 */
  static int next_pow2(int n) {
  int i = 0;
  while (n)
  ++i, n >>= 1;
  return 1 << i;
  }

  typedef struct arg_s {
  int c /* count */, n /* capacity */;
  char **v /* malloc */;
  } arg_t;

  static char *nextspace(const char *s) {
  while (*s && !isspace(*s))
  ++s;
  return (char *) s;
  }

  static char *skipspace(const char *s) {
  while (isspace(*s))
  ++s;
  return (char *) s;
  }

  static arg_t split_argv(int argc, char **old_argv) {
  /* argc does not count the trailing NULL pointer in argv */
  size_t argn = next_pow2(argc + 1);
  char **argv = (char **) malloc(sizeof(char *) * argn);

  int in = 0, out = 0;
  argv[out++] = strdup(old_argv[in++]);

  if (in >= argc)
  goto done;

  /* split old_argv[1] */
  char *stop, *start;
  for (start = old_argv[in++]; *start; start = stop) {
  start = skipspace(start), stop = nextspace(start);
  if (start == stop) break;  /* trailing space */
  argv[out++] = strndup(start, stop - start);
  if (argn <= out)
  argn <<= 1, argv = (char **) realloc(argv, sizeof(char *) * argn);
  /* if realloc() fails, just segmentation fault on NULL access */
  }

  /* copy the remaining arguments */
  while (in < argc) {
  argv[out++] = strdup(old_argv[in++]);
  if (argn <= out)
  argn <<= 1, argv = (char **) realloc(argv, sizeof(char *) * argn);
  /* if realloc() fails, just segmentation fault on NULL access */
  }

  done:
  argv[out] = NULL;

  struct arg_s r = { out, argn, argv };
  return r;
  }

  static int find_dashdash(int argc, char **argv, int i) {
  while (i < argc) {
  if (strcmp("--", argv[i]) == 0)
  return i;
  ++i;
  }
  return -1;
  }

  int main(int argc, char **argv) {
  sanitize_environ(environ);

  const char *self = argv[0];
  struct stat statself;
  if (stat(self, &statself) < 0)
  return perror(self), EX_IOERR;

  if (statself.st_mode & S_ISUID) {
  if (geteuid() != statself.st_uid) {  /* OS ignored our setuid bit, */
  execv(argv[0], argv);  /* rerun self to get setuid back. */
  return perror(argv[0]), EX_OSERR;
  }
  }

  arg_t arg = split_argv(argc, argv);

  int dashdash = find_dashdash(arg.c, arg.v, 2);
  if (dashdash < 0 || dashdash + 1 >= arg.c)
  return fputs(usage, stderr), EX_USAGE;

  const char *interp = arg.v[1], *script = arg.v[dashdash + 1];

  /* access() checks permission using real uid and gid (set to the
  * invoking user) as opposed to the effective uid and gid (set to
  * the binary).
  */
  if (access(interp, X_OK) < 0)
  return perror(interp), EX_NOPERM;
  if (access(script, X_OK | R_OK) < 0)
  return perror(script), EX_NOPERM;

  int fd = open(script, O_RDONLY);
  if (fd < 0)
  return perror(script), EX_NOPERM;

  char buf[16];
  snprintf(buf, sizeof(buf), "/dev/fd/%d", fd);

  struct stat statbuf;
  if (fstat(fd, &statbuf) < 0)
  return perror(script), EX_IOERR;

  #define SETEXID(xid, S_ISXID) \
  if (sete##xid(statbuf.st_mode & S_ISXID ? \
  statbuf.st_##xid : get##xid()) < 0) \
  return perror("sete" #xid), EX_NOPERM;

  /* set effective gid first, or we might not be able to do that after
  * setting effective uid away from root.
  */
  SETEXID(gid, S_ISGID);
  SETEXID(uid, S_ISUID);
  #undef SETEXID

  arg.v[dashdash + 1] = buf;  /* override script to fd */
  execv(arg.v[1], arg.v + 1);  /* normally should not return. */
  return perror(arg.v[1]), EX_OSERR;
  }