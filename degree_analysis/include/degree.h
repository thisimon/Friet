#ifndef hDegree
#define hDegree

#include "friet.h"
#include <stdint.h>
#include <string.h> 
#include <stdlib.h> 

void setbit(State s, uint32_t bit);
void initializeTruthTable( uint8_t *truthTable, uint32_t *indexes, uint32_t size, uint32_t round, uint32_t bit );
void initializeTruthTableInv( uint8_t *truthTable, uint32_t *indexes, uint32_t size, uint32_t round, uint32_t bit );
void ANF(uint8_t *truthTable, uint32_t size);
int getDegree(uint8_t *truthTable, uint32_t size);
uint32_t testDegree( uint32_t *indexes, uint32_t size, uint32_t round, uint32_t bit );
uint32_t testDegreeInv( uint32_t *indexes, uint32_t size, uint32_t round, uint32_t bit );
void printMonomial( uint32_t bit );
void printParents( uint32_t bit );

#endif