#include "friet.h"

const int NLIMB = 4;
const uint8_t MASK32 = 0x1f;
const uint8_t MASK4 = 0x3;
const uint32_t ROUND_CONSTANT[24] = 
{
    0x00001111, // 0
    0x11100000, // 1
    0x00001101, // 2
    0x10100000, // 3
    0x00000101, // 4
    0x10110000, // 5
    0x00000110, // 6
    0x11000000, // 7
    0x00001001, // 8
    0x00100000, // 9
    0x00000100, // 10
    0x10000000, // 11
    0x00000001, // 12
    0x00110000, // 13
    0x00000111, // 14
    0x11110000, // 15
    0x00001110, // 16
    0x11010000, // 17
    0x00001010, // 18
    0x01010000, // 19
    0x00001011, // 20
    0x01100000, // 21
    0x00001100, // 22
    0x10010000  // 23
};

/*
 * Print a 128-bit integer in hexadecimal
 */
void printlimb(bigint a) 
{
	int i;
	for(i = 0; i < NLIMB; i++) {
		printf("%08x", a[i]);
	}
	printf("\n");
	return;
}

/*
 * Rotate a 128-bit integer @src of @n bits to the left.
 * The result is stored in @dest.
 */
void bitrol(bigint src, bigint dest, int n) 
{
	int i;
	int shift = n >> 5;
	int rot = n & MASK32;

	for(i = 0; i < NLIMB; i++) {
		dest[i] = src[(i + shift) & MASK4] << rot;
		if(rot != 0) {
			dest[i] ^= src[(i + shift + 1) & MASK4] >> (32 - rot);
		}
	}
}

/*
 * Exclusive OR two 128-bit integers @a and @b .
 * The result is stored in @dest.
 */
void xor(bigint a, bigint b, bigint dest) 
{
	int i;
	/*memset(dest, 0, sizeof(bigint));*/
	for(i = 0; i < NLIMB; i++) {
		dest[i] = a[i] ^ b[i];
	}
}

/*
 * Bitwise AND two 128-bit integers @a and @b .
 * The result is stored in @dest.
 */
void and(bigint a, bigint b, bigint dest) 
{
	int i;
	for(i = 0; i < NLIMB; i++) {
		dest[i] = a[i] & b[i];
	}
}

/*
 * Bitwise OR two 128-bit integers @a and @b .
 * The result is stored in @dest.
 */
void or(bigint a, bigint b, bigint dest) 
{
	int i;
	for(i = 0; i < NLIMB; i++) {
		dest[i] = a[i] | b[i];
	}
}

/*
 * Copy a 128-bit integer @src into @dest.
 */
void copy(bigint src, bigint dest) 
{
	int i;
	for(i = 0; i < NLIMB; i++) {
		dest[i] = src[i];
	}
}

void round_bare(bigint a, bigint b, bigint c)
{
    bigint s = {0x00000000, 0x00000000, 0x00000000, 0x00000000};
	bigint t = {0x00000000, 0x00000000, 0x00000000, 0x00000000};

	/* Permutation step   */
	copy(b, s);
	copy(c, b);
	copy(a, c);

	/* XOR step           */
	xor(s, b, a);
	xor(a, c, a);

	/* First mixing step  */
	bitrol(c, s, 1);
	xor(b, s, b);

	/* Second Mixing step */
	bitrol(b, s, 80);
	xor(c, s, c);

	/* XOR step           */
	xor(a, b, b);
	xor(b, c, b);

	/* Non linear step    */
	bitrol(b, s, 36);
	bitrol(c, t, 67);
	and(s, t, s);
	xor(s, a, a);
}

void fast_round_bare( State s )
{
    uint32_t temp, temp2;

    // b = a ^ b ^ c
    s[4] ^= s[0] ^ s[8];
    s[5] ^= s[1] ^ s[9];
    s[6] ^= s[2] ^ s[10];
    s[7] ^= s[3] ^ s[11];

    // (a, b, c) = (b, c, a)
    temp = s[0];
    s[0] = s[4];
    s[4] = s[8];
    s[8] = temp;
    temp = s[1];
    s[1] = s[5];
    s[5] = s[9];
    s[9] = temp;
    temp = s[2];
    s[2] = s[6];
    s[6] = s[10];
    s[10] = temp;
    temp = s[3];
    s[3] = s[7];
    s[7] = s[11];
    s[11] = temp;

    /* First mixing step: b ^= bitrol(c, 1) */
    s[4] ^= ( s[8] << 1 ) ^ ( s[9] >> 31 );
    s[5] ^= ( s[9] << 1 ) ^ ( s[10] >> 31 );
    s[6] ^= ( s[10] << 1 ) ^ ( s[11] >> 31 );
    s[7] ^= ( s[11] << 1 ) ^ ( s[8] >> 31 );

    /* Second Mixing step: c ^= bitrol(b, 80) */
    s[8] ^= ( s[6] << 16 ) ^ ( s[7] >> 16 );
    s[9] ^= ( s[7] << 16 ) ^ ( s[4] >> 16 );
    s[10] ^= ( s[4] << 16 ) ^ ( s[5] >> 16 );
    s[11] ^= ( s[5] << 16 ) ^ ( s[6] >> 16 );

    /* b = a ^ b ^ c */
    s[4] ^= s[0] ^ s[8];
    s[5] ^= s[1] ^ s[9];
    s[6] ^= s[2] ^ s[10];
    s[7] ^= s[3] ^ s[11];

    /* Non linear step */
    temp = s[5] << 4;
    temp ^= s[6] >> 28;
    temp2 = s[10] << 3;
    temp2 ^= s[11] >> 29;
    s[0] ^= temp & temp2;
    temp = s[6] << 4;
    temp ^= s[7] >> 28;
    temp2 = s[11] << 3;
    temp2 ^= s[8] >> 29;
    s[1] ^= temp & temp2;
    temp = s[7] << 4;
    temp ^= s[4] >> 28;
    temp2 = s[8] << 3;
    temp2 ^= s[9] >> 29;
    s[2] ^= temp & temp2;
    temp = s[4] << 4;
    temp ^= s[5] >> 28;
    temp2 = s[9] << 3;
    temp2 ^= s[10] >> 29;
    s[3] ^= temp & temp2;
}

void fast_inv_round_bare( State s )
{
    uint32_t temp, temp2;

    /* Non linear step */
    temp = s[5] << 4;
    temp ^= s[6] >> 28;
    temp2 = s[10] << 3;
    temp2 ^= s[11] >> 29;
    s[0] ^= temp & temp2;
    temp = s[6] << 4;
    temp ^= s[7] >> 28;
    temp2 = s[11] << 3;
    temp2 ^= s[8] >> 29;
    s[1] ^= temp & temp2;
    temp = s[7] << 4;
    temp ^= s[4] >> 28;
    temp2 = s[8] << 3;
    temp2 ^= s[9] >> 29;
    s[2] ^= temp & temp2;
    temp = s[4] << 4;
    temp ^= s[5] >> 28;
    temp2 = s[9] << 3;
    temp2 ^= s[10] >> 29;
    s[3] ^= temp & temp2;

    /* b = a ^ b ^ c */
    s[4] ^= s[0] ^ s[8];
    s[5] ^= s[1] ^ s[9];
    s[6] ^= s[2] ^ s[10];
    s[7] ^= s[3] ^ s[11];

    /* Second Mixing step: c ^= bitrol(b, 80) */
    s[8] ^= ( s[6] << 16 ) ^ ( s[7] >> 16 );
    s[9] ^= ( s[7] << 16 ) ^ ( s[4] >> 16 );
    s[10] ^= ( s[4] << 16 ) ^ ( s[5] >> 16 );
    s[11] ^= ( s[5] << 16 ) ^ ( s[6] >> 16 );

    /* First mixing step: b ^= bitrol(c, 1) */
    s[4] ^= ( s[8] << 1 ) ^ ( s[9] >> 31 );
    s[5] ^= ( s[9] << 1 ) ^ ( s[10] >> 31 );
    s[6] ^= ( s[10] << 1 ) ^ ( s[11] >> 31 );
    s[7] ^= ( s[11] << 1 ) ^ ( s[8] >> 31 );

    // (a, b, c) = (c, a, b)
    temp = s[0];
    s[0] = s[8];
    s[8] = s[4];
    s[4] = temp;
    temp = s[1];
    s[1] = s[9];
    s[9] = s[5];
    s[5] = temp;
    temp = s[2];
    s[2] = s[10];
    s[10] = s[6];
    s[6] = temp;
    temp = s[3];
    s[3] = s[11];
    s[11] = s[7];
    s[7] = temp;

    // b = a ^ b ^ c
    s[4] ^= s[0] ^ s[8];
    s[5] ^= s[1] ^ s[9];
    s[6] ^= s[2] ^ s[10];
    s[7] ^= s[3] ^ s[11];
}

/*
 * One round of Friet
 */
void friet_round(bigint a, bigint b, bigint c, int i)
{
	/* Round constant addition */
	c[3] = c[3] ^ ROUND_CONSTANT[i];

	round_bare(a, b, c);
}

void lambda( State state )
{
    uint32_t *a, *b, *c;
    Limb s;
    a = &state[0];
    b = &state[4];
    c = &state[8];

    /* Permutation step */
    copy(b, s);
    copy(c, b);
    copy(a, c);

    /* XOR step */
    xor(s, b, a);
    xor(a, c, a);

    /* First mixing step: b ^= bitrol(c, 1) */
    b[0] ^= ( c[0] << 1 ) ^ ( c[1] >> 31 );
    b[1] ^= ( c[1] << 1 ) ^ ( c[2] >> 31 );
    b[2] ^= ( c[2] << 1 ) ^ ( c[3] >> 31 );
    b[3] ^= ( c[3] << 1 ) ^ ( c[0] >> 31 );

    /* Second Mixing step: c ^= bitrol(b, 80) */
    c[0] ^= ( b[2] << 16 ) ^ ( b[3] >> 16 );
    c[1] ^= ( b[3] << 16 ) ^ ( b[0] >> 16 );
    c[2] ^= ( b[0] << 16 ) ^ ( b[1] >> 16 );
    c[3] ^= ( b[1] << 16 ) ^ ( b[2] >> 16 );

    /* XOR step */
    xor(a, b, b);
    xor(b, c, b);
}

void lambdaTransposed( State state )
{
    uint32_t *a, *b, *c;
    Limb s;
    a = &state[0];
    b = &state[4];
    c = &state[8];

    /* Transpose of tau2: (a, b, c) = (a^b, b, b^c) */
    xor(a, b, a);
    xor(c, b, c);

    /* Transpose of mu2: (a, b, c) = (a, b^bitrol(c, 48), c) */
    b[0] ^= ( c[1] << 16 ) ^ ( c[2] >> 16 );
    b[1] ^= ( c[2] << 16 ) ^ ( c[3] >> 16 );
    b[2] ^= ( c[3] << 16 ) ^ ( c[0] >> 16 );
    b[3] ^= ( c[0] << 16 ) ^ ( c[1] >> 16 );

    /* Transpose of mu1: (a, b, c) = (a, b, c^bitrol(b, 127)) */
    c[0] ^= ( b[1] << 31 ) ^ ( b[0] >> 1 );
    c[1] ^= ( b[2] << 31 ) ^ ( b[1] >> 1 );
    c[2] ^= ( b[3] << 31 ) ^ ( b[2] >> 1 );
    c[3] ^= ( b[0] << 31 ) ^ ( b[3] >> 1 );

    /* Transpose of tau1: (a, b, c) = (a^c, a, a^b) */
    xor(a, c, s);
    xor(a, b, c);
    copy(a, b);
    copy(s, a);
}
