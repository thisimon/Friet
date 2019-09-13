#include "trail_lin.h"

static inline uint32_t getCorrWeight( State mask )
{
    int i;

    uint32_t weight = 128;

    for( i = 0; i < 32; i++ )
    {
        weight -= ((mask[0] >> i) & 1) - ((mask[1] >> i) & 1) -
        ((mask[2] >> i) & 1) - ((mask[3] >> i) & 1);
    }

    return weight;
}
