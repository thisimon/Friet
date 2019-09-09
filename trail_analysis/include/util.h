#ifndef hTrailUtil
#define hTrailUtil

#include <string.h>
#include <stdint.h>
#include <stdio.h>

#define NLIMB 3
#define LIMBSIZE 4
#define STATESIZE 12
#define ROUND 10

/*
** Type definitions
*/
typedef uint32_t State[12];
typedef uint32_t Limb[4];
typedef uint32_t Mask[4];

typedef struct Trail
{
    uint32_t weight[ROUND];
    uint32_t state[3*4*ROUND];
} Trail;

/*
** Function definitions
*/
void printlimb(Limb a);
void printTrail( Trail trail, uint32_t nround );
void copyState( State src, State dest );
void pushState( Trail* trail, State state, uint32_t weight, uint32_t n );

#endif