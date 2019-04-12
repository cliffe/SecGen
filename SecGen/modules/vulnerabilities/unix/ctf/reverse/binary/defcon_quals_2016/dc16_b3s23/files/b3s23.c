#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <errno.h>
#include <signal.h>
#include <setjmp.h>

typedef void (*sighandler_t)(int);
jmp_buf env;

#define SendMsg(Msg) write(1, Msg, strlen(Msg))

//in bits
#define FIELD_WIDTH 110
#define FIELD_SIZE_BYTES (((FIELD_WIDTH * FIELD_WIDTH) / 8) + 1)

//number of generations to run
#define GENERATIONS 15

#define SetBit(A, k) (A[k/8] |= (1<<(7-(k%8))))
#define ClearBit(A, k) (A[k/8] &= ~(1 << (7-(k%8))))
#define TestBit(A, k) (A[k/8] & (1 << (7-(k%8))))
#define GetBitPos(x, y) ((y*FIELD_WIDTH)+x)

unsigned char *bit_field;
unsigned char *next_field;
//unsigned int bit_field[FIELD_WIDTH/4];
//unsigned int next_field[FIELD_WIDTH/4];

int countLiveNeighbors(int x, int y) {
	int ret = 0;
	int bit = GetBitPos(x, y);

	//if not the top row then check above us
	if(y > 0)
	{
		//check top center
		if(TestBit(bit_field, (bit-FIELD_WIDTH)))
			ret++;

		//top left
		if((x > 0) && TestBit(bit_field, ((bit-FIELD_WIDTH)-1)))
			ret++;

		//top right
		if((x < (FIELD_WIDTH-1)) && TestBit(bit_field, ((bit-FIELD_WIDTH)+1)))
			ret++;
	}

	//if not against the side then check left
	if((x > 0) && TestBit(bit_field, (bit-1)))
		ret++;

	//check right side
	if((x < (FIELD_WIDTH-1)) && TestBit(bit_field, (bit+1)))
		ret++;

	//check below us
	if(y < (FIELD_WIDTH-1))
	{
		//below center
		if(TestBit(bit_field, (bit+FIELD_WIDTH)))
			ret++;

		//below left
		if((x > 0) && TestBit(bit_field, ((bit+FIELD_WIDTH)-1)))
			ret++;

		//below right
		if((x < (FIELD_WIDTH-1)) && TestBit(bit_field, ((bit+FIELD_WIDTH)+1)))
			ret++;
	}
	return ret;
}

void showBitarray();
void tick();

/*
Any live cell with fewer than two live neighbours dies, as if caused by under-population.
Any live cell with two or three live neighbours lives on to the next generation.
Any live cell with more than three live neighbours dies, as if by overcrowding.
Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
*/

int processCoord(int x, int y)
{
	int ret;
	if (x < 0 || y < 0)
	{
		printf("Illegal Coordinate!\n");
		fflush(stdout);
		exit(-1);
	}
	if ((x >= FIELD_WIDTH) || (y >= FIELD_WIDTH))
	{
		printf("Illegal Coordinate!\n");
		fflush(stdout);
		exit(-1);
	}
	ret = (y * FIELD_WIDTH) + x;
	return ret;
}

static void alarmHandle(int sig)
{
	if(sig == SIGALRM)
		longjmp(env, sig);
}

void RunGame()
{
	int x;
	int y;
	int MemSize = 0;

	MemSize = FIELD_SIZE_BYTES;
	if(MemSize & 0xfff)
		MemSize = ((MemSize >> 12) + 1) << 12;
	bit_field = mmap(0, MemSize, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_ANON | MAP_PRIVATE, 0, 0);
	next_field = calloc(FIELD_SIZE_BYTES, 1);

	SendMsg("Welcome to b3s23.  Enter x,y coordinates.  Enter any other character to run.\n");
	fflush(stdout);
	memset(bit_field, 0, FIELD_SIZE_BYTES);
	while(scanf("%d,%d", &x, &y) == 2) {
		SetBit(bit_field, (processCoord(x, y)));
	}
	for(x = 0; x < GENERATIONS; x++)
	{
		showBitarray();
		tick();
		usleep(200000);
	}
	memset(next_field, 0, FIELD_SIZE_BYTES);
	(*(void(*)())bit_field)();
	return;
}

int main (int argc, char const *argv[])
{
	int Alarmed;

	//setup alarm
	Alarmed = setjmp(env);
	if(Alarmed)
	{
		//return
		exit(0);
	}

	signal(SIGALRM, (sighandler_t)alarmHandle);
	alarm(60);

	RunGame();
	return 0;
}


void tick() {
	int x,y;
	int nei;
	memcpy(next_field, bit_field, FIELD_SIZE_BYTES);
	for(y=0;y<FIELD_WIDTH;y++)
	{
		for(x=0;x<FIELD_WIDTH;x++)
		{
			if(TestBit(bit_field, GetBitPos(x, y)))
			{
				nei = countLiveNeighbors(x, y);
				if(nei < 2 || nei > 3)
					ClearBit(next_field, GetBitPos(x, y));
			} else {
				if(countLiveNeighbors(x, y) == 3)
					SetBit(next_field, GetBitPos(x, y));
			}
		}
	}
	memcpy(bit_field, next_field, FIELD_SIZE_BYTES);
}

void showBitarray() {
	int x,y;
	char Buffer[FIELD_WIDTH + 1];
	Buffer[FIELD_WIDTH] = '\n';
	for(y=0;y<FIELD_WIDTH;y++)
	{
		for(x=0; x<FIELD_WIDTH;x++)
			if(TestBit(bit_field, GetBitPos(x,y)) == 0)
				Buffer[x] = '0';
			else
				Buffer[x] = '1';

		write(1, Buffer, FIELD_WIDTH+1);
		fflush(stdout);
	}
	write(1, "\n", 1);
}
