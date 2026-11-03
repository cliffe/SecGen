/* 
 *
 * This program inverts the colors of a PPM image using MPI parallelsm.
 * The root process acts as a master and sends a portion of the input
 * image to each child process. Master and child processes then
 * all invert the colors of the pixels of the portion of the image
 * assigned to them, and the child processes send their portions
 * of the image to the master, which outputs inverted.ppm.
 *
 * Adapted from the arraysum example from: 
 * Daniel Thomasset and Michael Grobe.
 * Introduction to the Message Passing Interface (MPI) Using C.
 * Online Tutorial Document, Academic Computing Services, 
 * The University of Kansas, November 2013. 
 * URL: http://condor.cc.ku.edu/~grobe/docs/intro-MPI-C.shtml
 */

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
   
#define max_rows 10000000
#define send_data_tag 2001
#define return_data_tag 2002
   
int main(int argc, char **argv) {
  long int sum, partial_sum;
  MPI_Status status;
  int my_id, root_process, ierr, i, num_rows, num_procs,
          an_id, num_rows_to_receive, avg_rows_per_process,
          sender, num_rows_received, start_row, end_row, num_rows_to_send;
  int width, height, max;
  FILE *infile;
  FILE *outfile;
  char name[256], buf[256];

  /* Now replicate this process to create parallel processes.
   * From this point on, every process executes a separate copy
   * of this program */

  ierr = MPI_Init(&argc, &argv);

  root_process = 0;

  /* find out MY process ID, and how many processes were started. */

  ierr = MPI_Comm_rank(MPI_COMM_WORLD, &my_id);
  ierr = MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

  if (my_id == root_process) {
    int *red, *green, *blue;

    /* I must be the root process, so I will query the user
     * to determine what image to process. */

    if (argc == 2) {
      infile = fopen(argv[1], "r");
    } else {
      printf("type the filename to open: \n");
      scanf("%s", name);
      infile = fopen(name, "r");
    }

    if (num_rows > max_rows) {
      fprintf(stderr, "error in setting num_rows to 0 and max_rows.\n");
      exit(1);
    }

    /* initialize an array */

    if (infile == NULL) {
      fprintf(stderr, "infile is equal to NULL\n");
      exit(1);
    }
    fgets(buf, 256, infile); // get the first line of the file
    fgets(buf, 256, infile); // get the second line of the file

    fgets(buf, 256, infile); // get the third line of the file


    sscanf(buf, "%d %d", &width, &height);

    if (width <= 0 || height <= 0) {
      fprintf(stderr, "malformed input file. width=%d height=%d\n", width, height);
      exit(1);
    }
    fscanf(infile, "%s", buf);
    sscanf(buf, "%d", &max);
    if (max <= 0) {
      fprintf(stderr, "malformed input file. max=%d\n", max);
      exit(1);
    }
printf("w=%d h=%d max=%d\n", width, height, max);
    red = (int *) malloc(width * height * sizeof(int));
    if (red == NULL) {
      fprintf(stderr, "malloc failure\n");
      exit(1);
    }
    green = (int *) malloc(width * height * sizeof(int));
    if (green == NULL) {
      fprintf(stderr, "malloc failure\n");
      exit(1);
    }
    blue = (int *) malloc(width * height * sizeof(int));
    if (blue == NULL) {
      fprintf(stderr, "malloc failure\n");
      exit(1);
    }
    fprintf(stderr, "malloc succeeded. this is a debug message.\n");
    for (i = 0; i < width * height; i++) {
      fscanf(infile, "%d", &red[i]);
      fscanf(infile, "%d", &green[i]);
      fscanf(infile, "%d", &blue[i]);
    }
    fclose(infile);

    num_rows = width * height;
    avg_rows_per_process = num_rows / num_procs;

    /* distribute a portion of the image to each child process */

    for (an_id = 1; an_id < num_procs; an_id++) {
      start_row = an_id * avg_rows_per_process;
      num_rows_to_send = avg_rows_per_process;

      fprintf(stderr, "about to send on %d\n", my_id);

      ierr = MPI_Send(&max, 1, MPI_INT,
                      an_id, send_data_tag, MPI_COMM_WORLD);

      ierr = MPI_Send(&num_rows_to_send, 1, MPI_INT,
                      an_id, send_data_tag, MPI_COMM_WORLD);

      ierr = MPI_Send(&red[start_row], num_rows_to_send, MPI_INT,
                      an_id, send_data_tag, MPI_COMM_WORLD);

      ierr = MPI_Send(&green[start_row], num_rows_to_send, MPI_INT,
                      an_id, send_data_tag, MPI_COMM_WORLD);

      ierr = MPI_Send(&blue[start_row], num_rows_to_send, MPI_INT,
                      an_id, send_data_tag, MPI_COMM_WORLD);

    }

    /* and invert the colors of the pixels in the segment assigned
     * to the root process */

    for (i = 0; i < avg_rows_per_process; i++) {
      red[i] = max - red[i];
      green[i] = max - green[i];
      blue[i] = max - blue[i];
    }

    /* and, finally, I collect the processed image portions
     * from the slave processes and output inverted.ppm. */

    for (an_id = 1; an_id < num_procs; an_id++) {
      start_row = an_id * avg_rows_per_process;
      num_rows_to_receive = avg_rows_per_process;

      fprintf(stderr, "about to receive on %d\n", my_id);

      ierr = MPI_Recv( &red[start_row], num_rows_to_receive, MPI_INT,
                       an_id, return_data_tag, MPI_COMM_WORLD, &status);

      ierr = MPI_Recv( &green[start_row], num_rows_to_receive, MPI_INT,
                       an_id, return_data_tag, MPI_COMM_WORLD, &status);

      ierr = MPI_Recv( &blue[start_row], num_rows_to_receive, MPI_INT,
                       an_id, return_data_tag, MPI_COMM_WORLD, &status);

      sender = status.MPI_SOURCE;

      if (sender != an_id) {
        fprintf(stderr, "problem with master receiving from slaves\n");
        exit(1);
      }
    }

    outfile = fopen("inverted.ppm", "w");
    fprintf(outfile, "P3\n");
    fprintf(outfile, "# CREATOR: GIMP PNM Filter Version 1.1\n");
    fprintf(outfile, "%d %d\n", width, height);
    fprintf(outfile, "%d\n", max);
    for (i = 0; i < width * height; i++) {
      fprintf(outfile, "%d\n", red[i]);
      fprintf(outfile, "%d\n", green[i]);
      fprintf(outfile, "%d\n", blue[i]);
    }
    fclose(outfile);
    free(red);
    free(green);
    free(blue);
  } else {
    int *red, *green, *blue;
    /* I must be a slave process, so I must receive my array segment,
     * storing it in a "local" array. */

    fprintf(stderr, "About to receive on slave %d\n", my_id);

    ierr = MPI_Recv(&max, 1, MPI_INT,
                    root_process, send_data_tag, MPI_COMM_WORLD, &status);

    ierr = MPI_Recv(&num_rows_to_receive, 1, MPI_INT,
                    root_process, send_data_tag, MPI_COMM_WORLD, &status);

    red = (int *) malloc(num_rows_to_receive * sizeof(int));
    if (red == NULL) {
      fprintf(stderr, "malloc failure on slave node\n");
      exit(1);
    }
    green = (int *) malloc(num_rows_to_receive * sizeof(int));
    if (green == NULL) {
      fprintf(stderr, "malloc faliure on slave node\n");
      exit(1);
    }
    blue = (int *) malloc(num_rows_to_receive * sizeof(int));
    if (blue == NULL) {
      fprintf(stderr, "malloc failure on slave node\n");
      exit(1);
    }

    ierr = MPI_Recv( red, num_rows_to_receive, MPI_INT,
                     root_process, send_data_tag, MPI_COMM_WORLD, &status);

    ierr = MPI_Recv( green, num_rows_to_receive, MPI_INT,
                     root_process, send_data_tag, MPI_COMM_WORLD, &status);

    ierr = MPI_Recv( blue, num_rows_to_receive, MPI_INT,
                     root_process, send_data_tag, MPI_COMM_WORLD, &status);

    num_rows_received = num_rows_to_receive;

    /* Invert my portion of the image */

    for (i = 0; i < num_rows_received; i++) {
      red[i] = max - red[i];
      green[i] = max - green[i];
      blue[i] = max - blue[i];
    }

    /* and finally, send my processed image portion to the master */

    fprintf(stderr, "about to send on  %d\n", my_id);

    ierr = MPI_Send(red, num_rows_received, MPI_INT,
                    root_process, return_data_tag, MPI_COMM_WORLD);

    ierr = MPI_Send(green, num_rows_received, MPI_INT,
                    root_process, return_data_tag, MPI_COMM_WORLD);

    ierr = MPI_Send(blue, num_rows_received, MPI_INT,
                    root_process, return_data_tag, MPI_COMM_WORLD);
    free(red);
    free(green);
    free(blue);
  }
  ierr = MPI_Finalize();
}
