#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <fcntl.h>

uint64_t exp_l( uint64_t base, uint64_t power)
{
	int i = 0;
	uint64_t j = base;

	if ( power == 0 ) {
		return 1;
	}

	for ( i = 0; i < power-1; i++) {
		j *= base;
	}

	return j;
}

uint64_t xor( uint64_t a, uint64_t b)
{
	return a ^ b;
}

uint64_t shla( uint64_t a, uint64_t dabits)
{
	uint64_t high = 0;
	uint64_t low = 0;

	dabits = dabits % 64;

	if ( dabits == 0 ) {
		return a;
	}

	high = a << dabits;
	low = a >> (64-dabits);

	return high | low;
}

uint64_t shra( uint64_t a, uint64_t dabits)
{
	uint64_t high = 0;
	uint64_t low = 0;

	dabits = dabits % 64;

	if ( dabits == 0 ) {
		return a;
	}

	low = a >> dabits;
	high = a << (64-dabits);

	return high | low;
}

/*
  0 1 2 3 4 5 6 7 
  5 0 4 6 7 3 1 2
*/
uint64_t swap_bytes( uint64_t value)
{
	uint64_t final = 0;

	final |= ( (value & 0xff) << 24);
	final |= ( (value & 0xff00) << 24);
	final |= ( (value & 0xff0000) << 40);
	final |= ( (value & 0xff000000) << 16);
	final |= ( (value & 0xff00000000) >> 16);
	final |= ( (value & 0xff0000000000) >> 40);
	final |= ( (value & 0xff000000000000) >> 40);
	final |= ( (value & 0xff00000000000000) >> 8);

	return final;
}

uint64_t swap_two( uint64_t value, uint64_t one, uint64_t two)
{
	uint64_t t_one = 0;
	uint64_t t_two = 0;

	uint64_t mask_one = 0xff;
	uint64_t mask_two = 0xff;

	mask_one <<= one*8;
	mask_two <<= two*8;

	mask_one ^= 0xffffffffffffffff;
	mask_two ^= 0xffffffffffffffff;

	t_one = (value >> (one*8)) & 0xff;
	t_two = (value >> (two*8)) & 0xff;

	/// Clear the bits
	value &= (mask_one & mask_two);

	value |= (t_two << ( one*8));
	value |= (t_one << ( two*8));

	return value;
}

uint64_t xor_neighbor( uint64_t value)
{
	int i = 0;
	uint64_t t = 0;

	t |= ((value & 0xff00000000000000) >> 8) ^ (value & 0xff000000000000);
	t |= ((value & 0xff000000000000) >> 8) ^ (value & 0xff0000000000);
	t |= ((value & 0xff0000000000) >> 8) ^ (value & 0xff00000000);
	t |= ((value & 0xff00000000) >> 8) ^ (value & 0xff000000);
	t |= ((value & 0xff000000) >> 8) ^ (value & 0xff0000);
	t |= ((value & 0xff0000) >> 8) ^ (value & 0xff00);
	t |= ((value & 0xff00) >> 8) ^ (value & 0xff);
	t |= ((value & 0xff) << 56) ^ (value & 0xff00000000000000);

	return t;
}

uint64_t munge_one( uint64_t value )
{
	value = xor( value, 0x35966a685c73335a);
	value = swap_two( value, 2, 0);
	value = xor( value, 0x89fdaf6604952df1);
	value = xor( value, 0xe9f30f0ce704876a);
	value = swap_two( value, 2, 3);
	value = xor( value, 0xbdc5026d3c0b56e6);
	value = shla( value, 16);
	value = shla( value, 35);
	value = shra( value, 19);
	value = xor_neighbor( value );
	value = shla( value, 36);
	value = shra( value, 40);
	value = swap_two( value, 1, 0);
	value = xor( value, 0x5de229fb3804db17);
	value = swap_bytes( value );
	value = swap_bytes( value );
	value = swap_two( value, 2, 1);
	value = xor( value, 0x6aad877366e921f5);
	value = swap_two( value, 3, 0);
	value = swap_bytes( value );
	value = xor( value, 0x58d83e9d5e6d5083);
	value = shra( value, 22);
	value = xor_neighbor( value );
	value = xor( value, 0x47b4d980070a9b73);
	value = xor_neighbor( value );
	value = xor_neighbor( value );
	value = swap_two( value, 6, 5);
	value = shla( value, 59);
	value = swap_two( value, 5, 2);
	value = swap_two( value, 2, 3);
	value = shla( value, 12);
	value = xor( value, 0xad25307f8e364b17);
	value = xor( value, 0x48a56d5afe0da4c2);
	value = shla( value, 6);
	value = swap_two( value, 6, 5);
	value = shra( value, 11);
	value = swap_bytes( value );
	value = xor( value, 0x869365db4c9f3cb6);
	value = swap_bytes( value );
	value = shra( value, 2);
	value = xor( value, 0x4085aa8c0693425b);
	value = shla( value, 35);
	value = shla( value, 9);
	value = xor_neighbor( value );
	value = shla( value, 7);
	value = shla( value, 38);
	value = xor_neighbor( value );
	value = xor( value, 0xdef2d72447ef4e1b);
	value = swap_bytes( value );
	value = swap_bytes( value );
	value = swap_two( value, 2, 7);
	value = shra( value, 51);
	value = swap_bytes( value );
	value = shra( value, 19);
	value = xor( value, 0x95de49591a44ee21);
	value = xor_neighbor( value );
	value = swap_bytes( value );
	value = shra( value, 16);
	return value;
}

uint64_t munge_two( uint64_t value )
{
	value = shla( value, 22);
	value = swap_bytes( value );
	value = swap_two( value, 4, 1);
	value = swap_bytes( value );
	value = xor_neighbor( value );
	value = shla( value, 35);
	value = swap_two( value, 2, 6);
	value = xor( value, 0x80a9ea4f90944fea);
	value = shla( value, 3);
	value = swap_two( value, 0, 1);
	value = swap_two( value, 1, 2);
	value = swap_bytes( value );
	value = xor_neighbor( value );
	value = swap_two( value, 5, 1);
	value = shra( value, 24);
	value = shla( value, 39);
	value = swap_two( value, 2, 4);
	value = xor( value, 0x678e70a16230a437);
	value = swap_two( value, 4, 3);
	value = swap_two( value, 0, 7);
	value = shla( value, 62);
	value = swap_bytes( value );
	value = swap_two( value, 7, 6);
	value = swap_two( value, 2, 6);
	value = swap_bytes( value );
	value = xor_neighbor( value );
	value = swap_two( value, 5, 2);
	value = xor_neighbor( value );
	value = swap_two( value, 1, 7);
	value = xor( value, 0x41ea5cf418a918e7);
	value = swap_bytes( value );
	value = xor_neighbor( value );
	value = swap_two( value, 1, 4);
	value = shla( value, 10);
	value = swap_bytes( value );
	value = swap_bytes( value );
	value = shra( value, 24);
	value = swap_two( value, 0, 4);
	value = shra( value, 61);
	value = swap_two( value, 3, 4);
	value = shra( value, 35);
	value = shla( value, 55);
	value = shla( value, 34);
	value = xor_neighbor( value );
	value = xor_neighbor( value );
	value = shra( value, 23);
	value = shla( value, 59);
	value = shra( value, 20);
	value = shla( value, 28);
	value = xor( value, 0xc26499379c0927cd);
	value = xor_neighbor( value );
	value = shra( value, 13);
	return value;
}

uint64_t munge_three( uint64_t value )
{
	value = shla( value, 18);
	value = shla( value, 29);
	value = swap_two( value, 5, 3);
	value = swap_two( value, 0, 7);
	value = shla( value, 18);
	value = xor( value, 0xc9ab604bb92038ad);
	value = shra( value, 33);
	value = swap_two( value, 0, 4);
	value = xor_neighbor( value );
	value = swap_two( value, 6, 2);
	value = shra( value, 13);
	value = shra( value, 20);
	value = xor( value, 0x58609be21eb37866);
	value = xor_neighbor( value );
	value = swap_bytes( value );
	value = shra( value, 46);
	value = swap_two( value, 2, 3);
	value = shra( value, 44);
	value = shra( value, 3);
	value = swap_two( value, 4, 3);
	value = xor_neighbor( value );
	value = swap_two( value, 7, 6);
	value = shra( value, 59);
	value = shra( value, 38);
	value = swap_bytes( value );
	value = swap_two( value, 1, 5);
	value = swap_bytes( value );
	value = shla( value, 27);
	value = xor( value, 0xbed577a97eb7966f);
	value = shra( value, 14);
	value = shla( value, 7);
	value = shla( value, 18);
	value = shla( value, 57);
	value = xor( value, 0xb44427be7889c31b);
	value = xor( value, 0xce745c65abecb66);
	value = xor( value, 0x94b1608adb7f7221);
	value = xor( value, 0x85bef139817ebc4a);
	value = swap_two( value, 5, 1);
	value = shla( value, 20);
	value = shla( value, 24);
	value = shra( value, 46);
	value = shra( value, 13);
	value = xor( value, 0xc95e5c35034b9775);
	value = shla( value, 7);
	value = xor( value, 0x8e60900383fa5ea);
	value = xor( value, 0x59d5bcbf8b0cc9fd);
	value = xor_neighbor( value );
	value = swap_two( value, 4, 7);
	value = xor_neighbor( value );
	value = shra( value, 22);
	value = shra( value, 50);
	value = xor_neighbor( value );
	return value;
}

uint64_t munge_four( uint64_t value )
{
	value = swap_two( value, 1, 7);
	value = shla( value, 6);
	value = swap_two( value, 2, 5);
	value = shra( value, 57);
	value = xor( value, 0xc852fa4047662ce);
	value = swap_two( value, 5, 1);
	value = shla( value, 1);
	value = xor_neighbor( value );
	value = xor( value, 0x5ddfc2422c2a449e);
	value = xor_neighbor( value );
	value = shla( value, 6);
	value = xor_neighbor( value );
	value = shla( value, 33);
	value = shra( value, 25);
	value = xor_neighbor( value );
	value = xor( value, 0xa94a4c87a942c60);
	value = swap_two( value, 6, 2);
	value = xor_neighbor( value );
	value = xor( value, 0xcc508fa31a0da5ab);
	value = xor( value, 0x880218b9f910dcbc);
	value = xor_neighbor( value );
	value = xor( value, 0x85d7e666ecdba611);
	value = shra( value, 8);
	value = shra( value, 43);
	value = xor( value, 0x633a915bd59ac97b);
	value = swap_two( value, 3, 1);
	value = swap_two( value, 5, 7);
	value = swap_bytes( value );
	value = xor_neighbor( value );
	value = shra( value, 59);
	value = shra( value, 10);
	value = xor_neighbor( value );
	value = swap_two( value, 2, 1);
	value = swap_two( value, 7, 2);
	value = xor_neighbor( value );
	value = xor( value, 0x648fff323d235735);
	value = xor( value, 0xfc9f8d635fd85eb3);
	value = xor( value, 0xff651571c16e5cb3);
	value = swap_two( value, 2, 4);
	value = swap_two( value, 5, 4);
	value = shra( value, 11);
	value = xor_neighbor( value );
	value = shla( value, 39);
	value = swap_bytes( value );
	value = xor_neighbor( value );
	value = xor( value, 0xc798d4e5c0e97b1c);
	value = swap_bytes( value );
	value = xor_neighbor( value );
	value = shla( value, 35);
	value = swap_two( value, 3, 5);
	value = xor_neighbor( value );
	value = swap_bytes( value );
	value = xor_neighbor( value );
	return value;
}

int munge_all( unsigned char *data )
{
	int i = 0;
	uint64_t *base = NULL;
	uint64_t one;
	uint64_t two;
	uint64_t thr;
	uint64_t fou;

	read( 0, data, 32);
	
	for ( i = 0; i < 32; i++ ) {
		if (  ((data[i] < 0x41) || ( 0x7a < data[i])) && (data[i] != 0x20) ) {
			return 0;
		} else if ( data[i] == ']') {
			return 0;
		} else if ( data[i] == '\\') {
			return 0;
		} else if ( data[i] == '^') {
			return 0;
		} else if ( data[i] == '`') {
			return 0;
		} else if ( data[i] == '[') {
			return 0;
		}
	}

	base = (uint64_t*)data;

	one = munge_one( base[0]);
	two = munge_two( base[1]);
	thr = munge_three( base[2]);
	fou = munge_four( base[3]);

	one = one^two^thr^fou;

	if ( one == 0xb101124831c0110a) {
		return 1;
	}

	return 0;
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

int main(int argc, char**argv)
{
	int fd;
	unsigned char data[32];

	bzero( data, 32 );

	if ( munge_all( data ) ) {
		printflag();
	}

	return 0;
}
