#include "degree.h"

/* Set a certain bit to 1 in the state */
void setbit(bigint a, bigint b, bigint c, uint32_t bit) {
	int word = bit / 128;
	int position = bit % 128;
	int limb = position / 32;

	position = position % 32;

	if(word == 0) a[limb] |= (1 << position);
	else if(word == 1) b[limb] |= (1 << position);
	else c[limb] |= (1 << position);
}

void initializeTruthTable( uint8_t* truthTable, uint32_t* indexes, uint32_t size, uint32_t round, int bit ) {
	bigint a = {0x00000000, 0x00000000, 0x00000000, 0x00000000};
	bigint b = {0x00000000, 0x00000000, 0x00000000, 0x00000000};
	bigint c = {0x00000000, 0x00000000, 0x00000000, 0x00000000};
	uint64_t i, j, temp;

	for( i = 0; i < ( 1 << size ); i++) {
		memset(a, 0, sizeof(bigint));
		memset(b, 0, sizeof(bigint));
		memset(c, 0, sizeof(bigint));

		for( j = 0; j < size; j++ ) {
			if ( i & ( 1 << j ) ) {
				setbit(a, b, c, indexes[j] );
			}
		}

		for(j = 0; j < round; j++) {
			round_bare(a, b, c);
		}

		if(bit == 0) temp = a[0] & 1;
		else if(bit == 1) temp = b[0] & 1;
		else temp = c[0] & 1;

		truthTable[i] = temp;
	}
}

void ANF(uint8_t* truthTable, uint32_t size) {
	uint64_t i, j, k, pow2n, pow2i;

	pow2n = 1 << size;
	for( i = 0; i < size; i++) {
		pow2i = 1 << i;
		for( j = 0; j < pow2n; j+=2*pow2i ) {
			for( k = 0; k < pow2i; k++ ) {
				truthTable[j + k + pow2i] ^= truthTable[j + k];
			}
		}
	}
}

int getDegree(uint8_t* truthTable, uint32_t size) {
	uint64_t i, h;
	uint32_t degree = 0;

	for( i = 0; i < ( 1 << size); i++ ) {
		if( truthTable[i] ) {
			h = hw_int( i );
			if( degree < h ) {
				degree = h;
			}
		}
	}

	return degree;
}