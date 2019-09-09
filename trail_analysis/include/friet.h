#ifndef hTrailFriet
#define hTrailFriet

#include "util.h"

void xor(Limb a, Limb b, Limb dest);
static inline void and(Limb a, Limb b, Limb dest);
static inline void copy(Limb src, Limb dest);
void lambda( State state );
void sanityTestLambda();

#endif