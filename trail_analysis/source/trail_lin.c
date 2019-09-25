#include "trail_lin.h"

static inline uint32_t getCorrWeight( State state, Limb maskB, Limb maskC )
{
    int i, j;
    uint8_t bit;
    Limb tempB = {0, 0, 0, 0};
    Limb tempC = {0, 0, 0, 0};

    uint32_t weight = 0;

    for( i = 0; i < 4; i++ )
    {
        for ( j = 0; j < 32; j++ )
        {
            bit = ( state[i] >> j ) & 1;
            weight += bit;
            if( bit == 1 )
            {
                tempB[i] |= ( 1 << j );
                tempC[i] |= ( 1 << j );
            }
        }
    }

    /* maskB = bitrol(tempB, 92) */
    maskB[0] = ( tempB[2] << 28 ) ^ ( tempB[3] >> 4 );
    maskB[1] = ( tempB[3] << 28 ) ^ ( tempB[0] >> 4 );
    maskB[2] = ( tempB[0] << 28 ) ^ ( tempB[1] >> 4 );
    maskB[3] = ( tempB[1] << 28 ) ^ ( tempB[2] >> 4 );

    /* maskC = bitrol(tempC, 61) */
    maskC[0] = ( tempC[1] << 29 ) ^ ( tempC[2] >> 3 );
    maskC[1] = ( tempC[2] << 29 ) ^ ( tempC[3] >> 3 );
    maskC[2] = ( tempC[3] << 29 ) ^ ( tempC[0] >> 3 );
    maskC[3] = ( tempC[0] << 29 ) ^ ( tempC[1] >> 3 );

    return 2*weight;
}

void sanityTestCorrWeight()
{
    uint32_t i, weight;
    uint32_t error = 0;
    State state = {0x5e5b4fd2, 0x2b68c687, 0x2872da1d, 0x381678b4,
                    0x16b57065, 0xdafce593, 0x163ea458, 0x9954c496,
                    0xe7466196, 0x773bc7fe, 0x53c2d88b, 0xc3c0f385};
    Limb maskB, maskC;
    Limb expectedMaskB = {0x33f853f9, 0x92371348, 0x88f44def, 0xaeb26a84};
    Limb expectedMaskC = {0x5d64d508, 0x67f0a7f3, 0x246e2691, 0x11e89bdf};
    lambdaTransposed( state );
    weight = getCorrWeight( state, maskB, maskC );

    for( i = 0; i < LIMBSIZE; i++ )
    {
        if ( maskB[i] != expectedMaskB[i] )
        {
            printf("Test of the correlation weight computation failed: the maskB is incorrect\n");
            printlimb( maskB );
            error = 1;
            break;
        }

        if ( maskC[i] != expectedMaskC[i] )
        {
            printf("Test of the correlation weight computation failed: the maskC is incorrect\n");
            printlimb( maskC );
            error = 1;
            break;
        }
    }

    if (weight != 130)
    {
        printf("Test of the correlation weight computation failed: weight was %d instead of 130\n", weight);
        error = 1;
    }

    if ( error == 0 )
    {
        printf("Sanity checks on the correlation weight computation passed succesfully\n");
    }
}

static inline void computeLinMask( Limb maskB, Limb maskC, Limb tempB, Limb tempC, uint32_t i )
{
  uint32_t j, k;
  uint32_t count = 0;
  memset((void *) tempB, 0, 4*sizeof(uint32_t));
  memset((void *) tempC, 0, 4*sizeof(uint32_t));

  for ( j = 0; j < 32; j++ )
  {
    for ( k = 0; k < LIMBSIZE; k++ )
    {
      if ( ( ( maskB[k] & ( 1 << j ) ) != 0 ) )
      {
        if ( ( ( i >> count ) & 1 ) != 0 )
        {
            tempB[k] ^= (1 << j);
        }
        count++;
      }
      if ( ( ( maskC[k] & ( 1 << j ) ) != 0 ) )
      {
        if ( ( ( i >> count ) & 1 ) != 0 )
        {
            tempC[k] ^= (1 << j);
        }
        count++;
      }
    }
  }
}

void linTrailSearch( Trail *trail, State state, Limb maskB, Limb maskC, uint32_t totalWeight, uint32_t weight, uint32_t totalRound, uint32_t nround, uint32_t bound )
{
    if ( nround == 0 )
    {
        printTrail( *trail, totalRound );
    }
    else
    {
        uint32_t i, *b, *c, newWeight, newTotalWeight;
        State newState;
        Limb tempB, tempC;
        b = &newState[4];
        c = &newState[8];

        for ( i = 0; i < (1 << weight); i++ )
        {
            copyState( state, newState );
            computeLinMask( maskB, maskC, tempB, tempC, i );
            xor( b, tempB, b );
            xor( c, tempC, c );
            lambdaTransposed( newState );
            newWeight = getCorrWeight( newState, tempB, tempC );
            newTotalWeight = totalWeight + newWeight;
            if ( newTotalWeight<= bound )
            {
                pushState( trail, newState, newWeight, totalRound - nround );
                if ( newWeight > 32 )
                {
                    printf("Warning: a weight > 32 has been encountered \n");
                    printTrail( *trail, totalRound - nround );
                }
                else
                {
                    linTrailSearch( trail, newState, tempB, tempC, newTotalWeight, newWeight, totalRound, nround-1, bound );
                }
            }
        }
    }
}

void linTrailSearchStart( Trail *trail, uint32_t bound, uint32_t nround )
{
    Limb maskB, maskC;
    uint32_t weight;
    State state = {0,0,0,1,0,0,0,0,0,0,0,0};
    weight = getCorrWeight( state, maskB, maskC );
    pushState( trail, state, weight, 0);
    linTrailSearch( trail, state, maskB, maskC, weight, weight, nround, nround-1, bound );
}

void linTrailSearchStart2bits( Trail *trail, uint32_t bound, uint32_t nround )
{
    Limb maskB, maskC;
    uint32_t weight, i;
    State state;
    for ( i = 1; i < 64; i++ )
    {
    memset( state, 0, 12*sizeof(uint32_t));
    state[3] = 1;
    state[3 - (i/32)] ^= (1 << (i % 32));
    weight = getCorrWeight( state, maskB, maskC );
        if (weight <= bound)
        {
            pushState(trail, state, weight, 0);
            linTrailSearch( trail, state, maskB, maskC, weight, weight, nround, nround-1, bound );
        }
    }
}

void linTrailSearchStart3bits( Trail *trail, uint32_t bound, uint32_t nround )
{
    Limb maskB, maskC;
    uint32_t weight, i, j;
    State state;
    for ( j = 1; j < 128; j++ )
    {
        for ( i = j; i < 128 - j; i++ )
        {
            memset( state, 0, 12*sizeof(uint32_t));
            state[3] = 1;
            state[3 - (i/32)] ^= (1 << (i % 32));
            state[3 - ((i+j)/32)] ^= (1 << ((i+j) % 32));
            weight = getCorrWeight( state, maskB, maskC );
            if (weight <= bound)
            {
                pushState(trail, state, weight, 0);
                linTrailSearch( trail, state, maskB, maskC, weight, weight, nround, nround-1, bound );
            }
        }
    }
}

void linTrailExtend( State state, uint32_t startWeight, uint32_t bound, uint32_t nround )
{
    Trail trail;
    Limb maskB, maskC;
    uint32_t weight;
    lambdaTransposed( state );
    weight = getCorrWeight( state, maskB, maskC );
    pushState( &trail, state, weight+startWeight, 0);
    linTrailSearch( &trail, state, maskB, maskC, weight+startWeight, weight, nround, nround-1, bound );
}
