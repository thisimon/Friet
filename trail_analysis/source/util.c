#include "util.h"

/*
 * Print an entire trail
 */
void printTrail( Trail trail, uint32_t nround )
{
  uint32_t i, j;
  uint32_t weight = 0;
  for ( i = 0; i < nround; i++ )
  {
    printf("( ");
    for ( j = 0; j < NLIMB; j++ )
    {
      printf("0x%08x%08x%08x%08x ", trail.state[STATESIZE*i+4*j],
        trail.state[STATESIZE*i+4*j+1], trail.state[STATESIZE*i+4*j+2],
        trail.state[STATESIZE*i+4*j+3]);
    }
    printf(")\t");
    weight += trail.weight[i];
  }
  printf("%d\n", weight);
}

/*
 * Copy a state @src into @dest.
 */
void copyState( State src, State dest )
{
  uint32_t i;
  for ( i = 0; i < STATESIZE; i++ )
  {
    dest[i] = src[i];
  }
}

void pushState( Trail* trail, State state, uint32_t weight, uint32_t n )
{
  uint32_t i;
  for ( i = 0; i < STATESIZE; i++ )
  {
    trail->state[STATESIZE*n+i] = state[i];
  }
  trail->weight[n] = weight;
}

