#ifndef hTrailLin
#define hTrailLin

#include "friet.h"

static inline uint32_t getCorrWeight( State state, Limb maskB, Limb maskC );
void sanityTestCorrWeight();
static inline void computeLinMask( Limb maskB, Limb maskC, Limb tempB, Limb tempC, uint32_t i );
void linTrailSearch( Trail *trail, State state, Limb maskB, Limb maskC, uint32_t totalWeight, uint32_t weight, uint32_t totalRound, uint32_t nround, uint32_t bound );
void linTrailSearchStart( Trail *trail, uint32_t bound, uint32_t nround );

#endif