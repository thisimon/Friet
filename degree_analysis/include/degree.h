#ifndef hDegree
#define hDegree

#include "friet.h"

void setbit(bigint a, bigint b, bigint c, uint32_t bit);
void initializeTruthTable( uint8_t* truthTable, uint32_t* indexes, uint32_t size, uint32_t round, int bit );
void ANF(uint8_t* truthTable, uint32_t size);
int getDegree(uint8_t* truthTable, uint32_t size);

#endif