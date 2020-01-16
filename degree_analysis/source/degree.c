#include "degree.h"

/* Set a certain bit to 1 in the state */
void setbit(State s, uint32_t bit) 
{
	int limb = bit / 128;
	int position = bit % 128;
	int word = 3 - position / 32;

	position = position % 32;

	s[4*limb + word] |= (1 << position);
}

uint32_t hw_int( uint64_t value )
{
	uint32_t i;
	uint32_t hw = 0;
	for( i = 0; i < 64; i++ ) {
		hw += value & 1;
		value >>= 1;
	}
	return hw;
}

void printTruthTable( uint8_t *truthTable, uint32_t size )
{
	uint32_t i;
	for( i = 0; i < (1 << size); i++ )
	{
		printf("%d: %d\n", i, truthTable[i]);
	}
}

void initializeTruthTable( uint8_t *truthTable, uint32_t *indexes, uint32_t size, uint32_t round, uint32_t bit ) 
{
	State s;
	uint64_t i, j, temp, bound;
	uint32_t limb, word, position;
	limb = bit / 128;
	word = 3 - (bit % 128) / 32;
	position = bit % 32;

	bound = 1;
	bound <<= size;
	for( i = 0; i < bound; i++) {
		memset(s, 0, sizeof(State));

		for( j = 0; j < size; j++ ) {
			temp = 1;
			temp <<= j;
			if ( i & temp ) {
				setbit(s, indexes[j] );
			}
		}

		for(j = 0; j < round; j++) {
			fast_round_bare(s);
		}

		temp = (s[4*limb + word] >> position) & 1;

		truthTable[i] = temp;
	}
}

void initializeTruthTableInv( uint8_t *truthTable, uint32_t *indexes, uint32_t size, uint32_t round, uint32_t bit ) 
{
	State s;
	uint64_t i, j, temp, bound;
	uint32_t limb, word, position;
	limb = bit / 128;
	word = 3 - (bit % 128) / 32;
	position = bit % 32;

	bound = 1;
	bound <<= size;
	for( i = 0; i < bound; i++) {
		memset(s, 0, sizeof(State));

		for( j = 0; j < size; j++ ) {
			temp = 1;
			temp <<= j;
			if ( i & temp ) {
				setbit(s, indexes[j] );
			}
		}

		for(j = 0; j < round; j++) {
			fast_inv_round_bare(s);
		}

		temp = (s[4*limb + word] >> position) & 1;

		truthTable[i] = temp;
	}
}

void ANF(uint8_t *truthTable, uint32_t size) 
{
	uint64_t i, j, k, pow2n, pow2i, temp;

	pow2n = 1;
	pow2n <<= size;
	for( i = 0; i < size; i++) {
		pow2i = 1;
		pow2i <<= i;
		temp = pow2i << 1;
		for( j = 0; j < pow2n; j += temp ) {
			for( k = 0; k < pow2i; k++ ) {
				truthTable[j + k + pow2i] ^= truthTable[j + k];
			}
		}
	}
}

int getDegree(uint8_t *truthTable, uint32_t size) 
{
	uint64_t i, h, bound;
	uint32_t degree = 0;

	bound = 1;
	bound <<= size;

	for( i = 0; i < bound; i++ ) {
		if( truthTable[i] ) {
			h = hw_int( i );
			if( degree < h ) {
				degree = h;
			}
		}
	}

	return degree;
}

uint32_t testDegree( uint32_t *indexes, uint32_t size, uint32_t round, uint32_t bit )
{
	uint32_t degree;
	uint64_t tableSize = 1;
	tableSize <<= size;
	uint8_t *truthTable = (uint8_t *) calloc(tableSize, sizeof(uint8_t));
	if (truthTable == NULL) {
		printf("Memory allocation failed, you wanted to allocate %lld bytes", tableSize);
	}
	initializeTruthTable( truthTable, indexes, size, round, bit );
	ANF( truthTable, size );
	degree = getDegree( truthTable, size );
	//printTruthTable( truthTable, size );
	printf("The algebraic degree of output bit %d of the state after %d rounds of Friet is %d\n", bit, round, degree);
	free( truthTable );
	return degree;
}

uint32_t testDegreeInv( uint32_t *indexes, uint32_t size, uint32_t round, uint32_t bit )
{
	uint32_t degree;
	uint64_t tableSize = 1;
	tableSize <<= size;
	uint8_t *truthTable = (uint8_t *) calloc(tableSize, sizeof(uint8_t));
	if (truthTable == NULL) {
		printf("Memory allocation failed, you wanted to allocate %lld bytes", tableSize);
	}
	initializeTruthTableInv( truthTable, indexes, size, round, bit );
	ANF( truthTable, size );
	degree = getDegree( truthTable, size );
	//printTruthTable( truthTable, size );
	printf("The algebraic degree of output bit %d of the state after %d rounds of Friet^{-1} is %d\n", bit, round, degree);
	free( truthTable );

	return degree;
}

void printMonomial( uint32_t bit )
{
	uint32_t limb, position;
	limb = bit / 128;
	position = bit % 128;
	printf("( ");
	if (limb == 0) {
		printf ("a_%d + a_%d + b_%d + c_%d )", (91 + position) % 128,  (11 + position) % 128, (92 + position) % 128, (12 + position) % 128);
		printf("( a_%d + a_%d + c_%d )\n",  (61 + position) % 128, (108 + position) % 128, (109 + position) % 128);
	}
}

void printParents( uint32_t bit )
{
	uint32_t limb, position;
	limb = bit / 128;
	position = bit % 128;
	if (limb == 0) {
		printf ("b_%d * c_%d \n", (12 + position) % 128 + 128,  (109 + position) % 128 + 256);
	}
	if (limb == 1) {
		printf ("b_%d * c_%d + b_%d * c_%d \n", (12 + position) % 128 + 128,  (109 + position) % 128 + 256, (11 + position) % 128 + 128,  (108 + position) % 128 + 256);
	}
	if (limb == 2) {
		printf ("b_%d * c_%d + b_%d * c_%d \n", (92 + position) % 128 + 128,  (61 + position) % 128 + 256, (11 + position) % 128 + 128,  (108 + position) % 128 + 256);
	}
}