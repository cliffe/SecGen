/* This program searches an array for a query number using MPI parallelism.
 * The root process acts as a master and sends a portion of the
 * array to each child process.  Master and child processes then
 * all search the portion of the array assigned to them.
 * If the process finds the query number in its portion of the array,
 * it outputs this fact to stdout.
 * 
 * Adapted from the arraysum.c example from:
 * Daniel Thomasset and Michael Grobe.
 * Introduction to the Message Passing Interface (MPI) Using C.
 * Online Tutorial Document, Academic Computing Services, 
 * The University of Kansas, November 2013. 
 * URL: http://condor.cc.ku.edu/~grobe/docs/intro-MPI-C.shtml
 **/

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
   
#define max_rows 1000000
#define send_data_tag 2001
#define return_data_tag 2002

int array[max_rows];
int array2[max_rows];
   
int main(int argc, char **argv) 
{
  MPI_Status status;
  int my_id, root_process, ierr, i, num_rows, num_procs,
    an_id, num_rows_to_receive, avg_rows_per_process, 
    sender, num_rows_received, start_row, end_row, num_rows_to_send, query;

  /* Now replicate this process to create parallel processes.
   * From this point on, every process executes a separate copy
   * of this program */

  ierr = MPI_Init(&argc, &argv);
  
  root_process = 0;
      
  /* find out MY process ID, and how many processes were started. */
      
  ierr = MPI_Comm_rank(MPI_COMM_WORLD, &my_id);
  ierr = MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

  if(my_id == root_process) {
         
    /* I must be the root process, so I will query the user. */

    if (argc==3) {
      num_rows = atoi( argv[1] );
      query = atoi(argv[2]);
    }
       else
    {
      printf("please enter the number of numbers to search: \n");
      scanf("%i", &num_rows);
      printf("please enter the number to search for: \n");
      scanf("%i", &query);
    }
    
    if(num_rows > max_rows) {
      printf("Too many numbers.\n");
      exit(1);
    }

    avg_rows_per_process = num_rows / num_procs;

    /* initialize an array */

    for(i = 0; i < num_rows; i++) {
      array[i] = i + 1;
    }

    /* distribute a portion of the array to each child process */
   
    for(an_id = 1; an_id < num_procs; an_id++) {
      start_row = an_id*avg_rows_per_process + 1;
      end_row   = (an_id + 1)*avg_rows_per_process;

      if((num_rows - end_row) < avg_rows_per_process)
        end_row = num_rows - 1;

      num_rows_to_send = end_row - start_row + 1;

      ierr = MPI_Send( &num_rows_to_send, 1 , MPI_INT,
                       an_id, send_data_tag, MPI_COMM_WORLD);

      ierr = MPI_Send( &array[start_row], num_rows_to_send, MPI_INT,
                       an_id, send_data_tag, MPI_COMM_WORLD);

      ierr = MPI_Send( &query, 1 , MPI_INT,
	an_id, send_data_tag, MPI_COMM_WORLD);


    }
        
    for(i = 0; i < avg_rows_per_process + 1; i++) {
      if (array[i] == query) {
	printf("FOUND %d in %d at %d!\n", query, my_id, i);
      }
    } 
  }

  else {

    /* I must be a slave process, so I must receive my array segment,
     * storing it in a "local" array. */

    ierr = MPI_Recv( &num_rows_to_receive, 1, MPI_INT, 
                     root_process, send_data_tag, MPI_COMM_WORLD, &status);

    ierr = MPI_Recv( &array2, num_rows_to_receive, MPI_INT, 
                     root_process, send_data_tag, MPI_COMM_WORLD, &status);

    ierr = MPI_Recv( &query, 1, MPI_INT, 
      root_process, send_data_tag, MPI_COMM_WORLD, &status);

    num_rows_received = num_rows_to_receive;

    for(i = 0; i < num_rows_received; i++) {
      if (array2[i] == query) {
	printf("FOUND %d in %d at %d!\n", query, my_id, i);
      }
    }
  }
  ierr = MPI_Finalize();
}
