#include "friet.h"

/*
 * Exclusive OR two limbs @a and @b .
 * The result is stored in @dest.
 */
void xor(Limb a, Limb b, Limb dest) 
{
	uint32_t i;
	for( i = 0; i < LIMBSIZE; i++ ) {
		dest[i] = a[i] ^ b[i];
	}
}

/*
 * Bitwise and two limbs @a and @b .
 * The result is stored in @dest.
 */
static inline void and(Limb a, Limb b, Limb dest) 
{
	uint32_t i;
	for( i = 0; i < LIMBSIZE; i++ ) {
		dest[i] = a[i] & b[i];
	}
}

/*
 * Copy a limb @src into @dest.
 */
static inline void copy(Limb src, Limb dest) 
{
	uint32_t i;
	for( i = 0; i < LIMBSIZE; i++ ) {
		dest[i] = src[i];
	}
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

/*
** Validating lambda function on a test vector
*/
void sanityTestLambda()
{
    uint32_t i;
    uint32_t error = 0;
    State state = {0x5e5b4fd2, 0x2b68c687, 0x2872da1d, 0x381678b4,
                    0x16b57065, 0xdafce593, 0x163ea458, 0x9954c496,
                    0xe7466196, 0x773bc7fe, 0x53c2d88b, 0xc3c0f385};
    State expectedState = {0xafa85e21, 0x86afe4ea, 0x6d8ea6ce, 0x62824fa7,
                            0xc6b25c2d, 0x8ec0336d, 0xb8e93188, 0xa38836d9,
                            0x32eafc3e, 0x29859d77, 0xd640fbf7, 0x72e67b93};
    lambda( state );
    Trail trail;

    for( i = 0; i < STATESIZE; i++ )
    {
        if ( state[i] != expectedState[i] )
        {
            printf("Test of lambda failed: the state is incorrect\n");
            pushState( &trail, state, 0, 0 );
            printTrail(trail, 1);
            error = 1;
            break;
        }
    }

    if ( error == 0 )
    {
        printf("Sanity checks on lambda passed succesfully\n");
    }
}