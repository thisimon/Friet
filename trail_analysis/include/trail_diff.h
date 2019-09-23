#ifndef hTrailDiff
#define hTrailDiff

#include "friet.h"

static inline uint32_t getDiffWeight( State state, Limb mask );
static inline void computeDiffMask( Limb mask, Limb temp, uint32_t i );
void diffTrailSearch( Trail *trail, State state, Limb mask, uint32_t totalWeight, uint32_t weight, uint32_t totalRound, uint32_t nround, uint32_t bound );
void diffTrailSearchStart( Trail *trail, uint32_t bound, uint32_t nround );
void diffTrailExtend( State state, uint32_t startWeight, uint32_t bound, uint32_t nround );
void sanityTestDiffWeight();

#endif