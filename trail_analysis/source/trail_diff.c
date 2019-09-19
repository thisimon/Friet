#include "trail_diff.h"

static inline uint32_t getDiffWeight( State state, Limb mask )
{
  uint32_t *b, *c, i;
  uint32_t weight = 0;
  b = &state[4];
  c = &state[8];

  /* mask = bitrol(b, 36) | bitrol(c, 67) */
  mask[0] = ((b[1] << 4) ^ (b[2] >> 28)) | ((c[2] << 3) ^ (c[3] >> 29));
  mask[1] = ((b[2] << 4) ^ (b[3] >> 28)) | ((c[3] << 3) ^ (c[0] >> 29));
  mask[2] = ((b[3] << 4) ^ (b[0] >> 28)) | ((c[0] << 3) ^ (c[1] >> 29));
  mask[3] = ((b[0] << 4) ^ (b[1] >> 28)) | ((c[1] << 3) ^ (c[2] >> 29));

  for( i = 0; i < 32; i++ )
  {
    weight += ((mask[0] >> i) & 1) + ((mask[1] >> i) & 1) +
    ((mask[2] >> i) & 1) + ((mask[3] >> i) & 1);
  }

  return weight;
}

static inline void computeDiffMask( Limb mask, Limb temp, uint32_t i )
{
  uint32_t j, k;
  uint32_t count = 0;
  memset((void *) temp, 0, 4*sizeof(uint32_t));

  for ( j = 0; j < 32; j++ )
  {
    for ( k = 0; k < LIMBSIZE; k++ )
    {
      if ( ( ( mask[k] & ( 1 << j ) ) != 0 ) )
      {
        if ( ( ( i >> count ) & 1 ) != 0 )
        {
            temp[k] ^= (1 << j);
        }
        count++;
      }
    }
  }
}

void diffTrailSearch( Trail *trail, State state, Limb mask, uint32_t totalWeight, uint32_t weight, uint32_t totalRound, uint32_t nround, uint32_t bound )
{
    if ( nround == 0 )
    {
        printTrail( *trail, totalRound );
    }
    else
    {
        uint32_t i, *a, newWeight, newTotalWeight;
        State newState;
        Limb temp;
        a = &newState[0];

        for ( i = 0; i < (1 << weight); i++ )
        {
            /*if ( nround == ROUND - 3 )
            {
            prog++;
            printf("Processing: %3d%%\r", (100 * prog) / 10615040 );
            fflush(stdout);
            }*/
            copyState( state, newState );
            computeDiffMask( mask, temp, i );
            xor( a, temp, a );
            lambda( newState );
            newWeight = getDiffWeight( newState, temp );
            newTotalWeight = totalWeight + newWeight;
            if ( newTotalWeight<= bound )
            {
                pushState( trail, newState, newWeight, totalRound - nround );
                if ( newWeight > 32 )
                {
                    printTrail( *trail, totalRound - nround );
                }
                else
                {
                    diffTrailSearch( trail, newState, temp, newTotalWeight, newWeight, totalRound, nround-1, bound );
                }
            }
        }
    }
}

void diffTrailSearchStart( Trail *trail, uint32_t bound, uint32_t nround )
{
    Limb mask;
    uint32_t weight;
    State state = {0,0,0,1,0,0,0,0,0,0,0,0};
    lambda( state );
    weight = getDiffWeight( state, mask );
    pushState( trail, state, weight, 0);
    diffTrailSearch( trail, state, mask, weight, weight, nround, nround-1, bound );
}

void diffTrailExtend( State state, uint32_t bound, uint32_t nround )
{
    Trail trail;
    Limb mask;
    uint32_t weight;
    lambda( state );
    weight = getDiffWeight( state, mask );
    pushState( &trail, state, weight+29, 0);
    diffTrailSearch( &trail, state, mask, weight+29, weight, nround, nround-1, bound );
}

void sanityTestDiffWeight()
{
    uint32_t i, weight;
    uint32_t error = 0;
    State state = {0x5e5b4fd2, 0x2b68c687, 0x2872da1d, 0x381678b4,
                    0x16b57065, 0xdafce593, 0x163ea458, 0x9954c496,
                    0xe7466196, 0x773bc7fe, 0x53c2d88b, 0xc3c0f385};
    Limb mask;
    Limb expectedMask = {0xfe07fffb, 0x9fb3dc9b, 0xbfd7edfd, 0x6f2debfe};
    lambda( state );
    weight = getDiffWeight( state, mask );

    for( i = 0; i < LIMBSIZE; i++ )
    {
        if ( mask[i] != expectedMask[i] )
        {
            printf("Test of the differential weight computation failed: the mask is incorrect\n");
            printlimb( mask );
            error = 1;
            break;
        }
    }

    if (weight != 95)
    {
        printf("Test of the differential weight computation failed: weight was %d instead of 95\n", weight);
        error = 1;
    }

    if ( error == 0 )
    {
        printf("Sanity checks on the differential weight computation passed succesfully\n");
    }
}