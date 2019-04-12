#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <signal.h>

#define FALSE 0
#define TRUE 1

#define MAX_IDLE_SECS	(150)
#define MAX_TRY_COUNT	(800)

char g_displayFoodString[1024];

void sig_alarm_handler( int signum )
{
	printf( "You ran out of time, closing!\n" );
	
	exit( 1 );
}

uint8_t ReadUint8( void )
{
	uint8_t temp;

	int data_read = read( 0, &temp, 1 );

	if ( data_read != 1 )
	{
		exit( -1  );
	}

	return temp;
}

void ReadData( uint8_t *pDest, uint32_t dataLen )
{
	uint32_t readRemaining = dataLen;
	uint32_t readPos = 0;
	while ( readRemaining > 0 )
	{
		int data_read = read( 0, pDest+readPos, readRemaining );	

		if ( data_read <= 0 )
		{
			// IO Error
			exit( -1 );
		}

		readPos += data_read;
		readRemaining -= data_read;
	}
}

void TestStackCheck( uint8_t i )
{
	char szTemp[32];

	if ( i > 0 )
	{
		uint32_t readValue = ReadUint8();

		ReadData( szTemp, readValue );

		printf( "%d%d\n", szTemp[30], szTemp[31] );
	}
}

uint8_t IntToHexChar( uint8_t val )
{
	if ( val < 10 )
		return '0' + val;
	else
		return 'a' + (val - 10);
}

char *ConvertDataBytes( char *pszData, uint8_t foodTotal, uint8_t maxConvert )
{
	uint32_t outIdx = 0;
	uint32_t i;
	int bTruncated = FALSE;

	if ( foodTotal > maxConvert )
	{
		bTruncated = TRUE;
		foodTotal = maxConvert;
	}

	for ( i = 0; i < maxConvert; i++ )
	{
		g_displayFoodString[outIdx++] = IntToHexChar( (pszData[i] >> 4) & 0xF );
		g_displayFoodString[outIdx++] = IntToHexChar( (pszData[i] ) & 0xF );
	}

	g_displayFoodString[outIdx] = '\0';

	if ( bTruncated )
		strcpy( g_displayFoodString+outIdx, "..." );

	return g_displayFoodString;
}

uint8_t GetFood( void )
{
	char szEchoData[32];
	uint8_t foodTotal;

	printf( "FEED ME!\n" );

	foodTotal = ReadUint8();
	
	ReadData( szEchoData, foodTotal );

	printf( "ATE %s\n", ConvertDataBytes( szEchoData, foodTotal, 16 ) );

	return foodTotal;
}

void RunFeedMe( void )
{
	int status = 0;
	uint32_t i;

	// Run loop
	for ( i = 0; i < MAX_TRY_COUNT; i++ )
	{
		pid_t child_pid = fork();

		if ( child_pid == 0 )
		{
			// Child
			printf( "YUM, got %d bytes!\n", GetFood() );
			break;
		}		
		else
		{
			pid_t wait_pid = waitpid( child_pid, &status, 0);

			if ( wait_pid == -1 )
			{
				printf( "Wait error!\n" );
				exit( -1 );
			}

			if ( status == -1 )
			{
				printf( "Child IO error!\n" );
				exit( -1 );
			}

			printf( "Child exit.\n" );
			fflush( 0 );
		}	
	}
}

int main( void )
{
	// Signal handler
	signal( SIGALRM, sig_alarm_handler );
	alarm( MAX_IDLE_SECS );

	// Update buffer
	setvbuf( stdout, NULL, _IONBF, 0 );

	fclose(stderr);

	// Run child feedme
	RunFeedMe();

	return 0;
}
