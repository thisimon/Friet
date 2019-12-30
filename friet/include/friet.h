#ifndef hFriet
#define hFriet

#include <stdio.h>
#include <stdint.h>

typedef uint32_t bigint[4]; /* 128-bit integer */
typedef uint32_t State[12];
typedef uint32_t Limb[4];

/*
 * Print a 128-bit integer in hexadecimal
 */
void printlimb(bigint a);

/*
 * Rotate a 128-bit integer @src of @n bits to the left.
 * The result is stored in @dest.
 */
void bitrol(bigint src, bigint dest, int n);

/*
 * Exclusive OR two 128-bit integers @a and @b .
 * The result is stored in @dest.
 */
void xor(bigint a, bigint b, bigint dest);

/*
 * Bitwise AND two 128-bit integers @a and @b .
 * The result is stored in @dest.
 */
void and(bigint a, bigint b, bigint dest);

/*
 * Bitwise OR two 128-bit integers @a and @b .
 * The result is stored in @dest.
 */
void or(bigint a, bigint b, bigint dest);

/*
 * Copy a 128-bit integer @src into @dest.
 */
void copy(bigint src, bigint dest);

/*
 * One round of Friet
 */
void friet_round(bigint a, bigint b, bigint c, int i);

void round_bare(bigint a, bigint b, bigint c);

void lambda( State state );
void lambdaTransposed( State state );
void sanityTestLambda();
void sanityTestLambdaTransposed();

#endif