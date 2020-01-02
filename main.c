#include "friet.h"
#include "trail_diff.h"
#include "trail_lin.h"
#include "degree.h"

void test_vector( void )
{
    int i;
	bigint a = {0x5e5b4fd2, 0x2b68c687, 0x2872da1d, 0x381678b4};
	bigint b = {0x16b57065, 0xdafce593, 0x163ea458, 0x9954c496};
	bigint c = {0xe7466196, 0x773bc7fe, 0x53c2d88b, 0xc3c0f385};
	bigint e = {0, 0, 0, 0};
	bigint f = {0, 0, 0, 0};
	bigint g = {0, 0, 0, 0};

	printf("Executing Friet on a test vector\n");
	printf("Input state:\n");
	printf("a = ");
	printlimb(a);
	printf("b = ");
	printlimb(b);
	printf("c = ");
	printlimb(c);

    copy(a,e);
    copy(b,f);
    copy(c,g);

	for(i = 0; i < 24; i++) {
		friet_round(a, b, c, i);
	}

	printf("Output state:\n");
	printf("a = ");
	printlimb(a);
	printf("b = ");
	printlimb(b);
	printf("c = ");
	printlimb(c);
}

/*
** Validating lambda function on a test vector
*/
void sanityTestLambda()
{
    uint32_t i;
    uint32_t error = 0;
    State state = {0x5e5b4fd2, 0x2b68c687, 0x2872da1d, 0x381678b4,
                    0x16b57065, 0xdafce593, 0x163ea458, 0x9954c496,
                    0xe7466196, 0x773bc7fe, 0x53c2d88b, 0xc3c0f385};
    State expectedState = {0xafa85e21, 0x86afe4ea, 0x6d8ea6ce, 0x62824fa7,
                            0xc6b25c2d, 0x8ec0336d, 0xb8e93188, 0xa38836d9,
                            0x32eafc3e, 0x29859d77, 0xd640fbf7, 0x72e67b93};
    lambda( state );
    Trail trail;

    for( i = 0; i < STATESIZE; i++ )
    {
        if ( state[i] != expectedState[i] )
        {
            printf("Test of lambda failed: the state is incorrect\n");
            pushState( &trail, state, 0, 0 );
            printTrail(trail, 1);
            error = 1;
            break;
        }
    }

    if ( error == 0 )
    {
        printf("Sanity checks on lambda passed succesfully\n");
    }
}

/*
** Validating the transpose of the lambda function on a test vector
*/
void sanityTestLambdaTransposed()
{
    uint32_t i;
    uint32_t error = 0;
    State state = {0x5e5b4fd2, 0x2b68c687, 0x2872da1d, 0x381678b4,
                    0x16b57065, 0xdafce593, 0x163ea458, 0x9954c496,
                    0xe7466196, 0x773bc7fe, 0x53c2d88b, 0xc3c0f385};
    State expectedState = {0x23713488, 0x8f44defa, 0xeb26a843, 0x3f853f99,
                            0x48ee3fb7, 0xf1942314, 0x3e4c7e45, 0xa142bc22, 
                            0x7c360a2e, 0x57bb9c13, 0x1f612bee, 0x29e5d573};

    lambdaTransposed( state );
    Trail trail;

    for( i = 0; i < STATESIZE; i++ )
    {
        if ( state[i] != expectedState[i] )
        {
            printf("Test of lambda transposed failed: the state is incorrect\n");
            pushState( &trail, state, 0, 0 );
            printTrail(trail, 1);
            error = 1;
            break;
        }
    }

    if ( error == 0 )
    {
        printf("Sanity checks on lambda transposed passed succesfully\n");
    }
}

void test_fast_round_bare( void )
{
    int i;
	State s = {0x5e5b4fd2, 0x2b68c687, 0x2872da1d, 0x381678b4, 0x16b57065, 0xdafce593, 0x163ea458, 0x9954c496, 0xe7466196, 0x773bc7fe, 0x53c2d88b, 0xc3c0f385};
    bigint a = {0x5e5b4fd2, 0x2b68c687, 0x2872da1d, 0x381678b4};
	bigint b = {0x16b57065, 0xdafce593, 0x163ea458, 0x9954c496};
	bigint c = {0xe7466196, 0x773bc7fe, 0x53c2d88b, 0xc3c0f385};
	bigint e = {0, 0, 0, 0};
	bigint f = {0, 0, 0, 0};
	bigint g = {0, 0, 0, 0};

	printf("Executing Friet on a test vector\n");
	printf("Input state:\n");
	printf("a = ");
	printlimb(a);
	printf("b = ");
	printlimb(b);
	printf("c = ");
	printlimb(c);

    round_bare(a, b, c);
    fast_round_bare(s);

	printf("Output state:\n");
	printlimb(a);
    printlimb((uint32_t *) &s[0]);
	printlimb(b);
    printlimb((uint32_t *) &s[4]);
	printlimb(c);
    printlimb((uint32_t *) &s[8]);
}

int main()
{
    /*
    ** Some sanity checks
    */
    /*sanityTestLambda();
    sanityTestDiffWeight();
    sanityTestLambdaTransposed();
    sanityTestCorrWeight();*/

    /*
    ** Looking from optimal differential trails starting from 1-bit differences
    */
    //Trail trail;
    // 1 round
    //diffTrailSearchStart( &trail, 4, 1 );
    // 2 rounds
    //diffTrailSearchStart( &trail, 10, 2 );
    // 3 rounds
    //diffTrailSearchStart( &trail, 18, 3 );
    // 4 rounds
    //diffTrailSearchStart( &trail, 29, 4 );
    // 5 rounds
    //diffTrailSearchStart( &trail, 44, 5 );

    /*
    ** Looking from optimal differential trails starting from 2-bit differences
    */
    //Trail trail;
    // 1 round
    //diffTrailSearchStart2bits( &trail, 6, 1 );
    // 2 rounds
    //diffTrailSearchStart2bits( &trail, 12, 2 );
    // 3 rounds
    //diffTrailSearchStart2bits( &trail, 22, 3 );
    // 4 rounds
    //diffTrailSearchStart2bits( &trail, 49, 4 );

    /*
    ** Looking from optimal differential trails starting from 3-bit differences
    */
    //Trail trail;
    // 1 round
    //diffTrailSearchStart3bits( &trail, 8, 1 );
    // 2 rounds
    //diffTrailSearchStart3bits( &trail, 14, 2 );
    // 3 rounds
    //diffTrailSearchStart3bits( &trail, 44, 3 );

    /*
    ** Extending the optimal differential trail starting from 1-bit difference on 4 rounds to 6 rounds
    */ 
    /*Trail trail;
    State state;
    diffTrailSearchStart( &trail, 29, 4 );
    copyState( &trail.state[STATESIZE * 3], state );
    diffTrailExtend( state, 59, 2 );*/

    /*
    ** Looking from optimal differential trails starting from 1-bit differences
    */
    //Trail trail;
    // 1 round
    //linTrailSearchStart( &trail, 2, 1 );
    // 2 rounds
    //linTrailSearchStart( &trail, 4, 2 );
    // 3 rounds
    //linTrailSearchStart( &trail, 6, 3 );
    // 4 rounds
    //linTrailSearchStart( &trail, 12, 4 );
    // 5 rounds
    //linTrailSearchStart( &trail, 22, 5 );
    // 6 rounds
    //linTrailSearchStart( &trail, 36, 6 );

    /*
    ** Looking from optimal linear trails starting from 2-bit masks
    */
    //Trail trail;
    // 1 round
    //linTrailSearchStart2bits( &trail, 4, 1 );
    // 2 rounds
    //linTrailSearchStart2bits( &trail, 8, 2 );
    // 3 rounds
    //linTrailSearchStart2bits( &trail, 12, 3 );
    // 4 rounds
    //linTrailSearchStart2bits( &trail, 20, 4 );

    /*
    ** Looking from optimal linear trails starting from 3-bit masks
    */
    //Trail trail;
    // 1 round
    //linTrailSearchStart3bits( &trail, 6, 1 );
    // 2 rounds
    //linTrailSearchStart3bits( &trail, 8, 2 );
    // 3 rounds
    //linTrailSearchStart3bits( &trail, 14, 3 );
    // 4 rounds
    //linTrailSearchStart3bits( &trail, 28, 4 );

    /*
    ** Extending the optimal differential trail starting from 1-bit mask on 6 rounds to 7 rounds
    */ 
    /*State state = {0x00004001, 0x00000000, 0x40014000, 0x80008000, 
                    0x00000000, 0x00000000, 0x40010000, 0x80000000,
                    0x00008000, 0x00000000, 0x40018000, 0x80010001};
    linTrailExtend( state, 36, 80, 2 );*/
    //test_vector();

    /*
    ** Finding the algebraic degree of a few iterations of the round function
    */
    /*uint32_t indexes_1rounds[2] = {61, 91};
    uint32_t indexes_2rounds[4] = {54, 71, 72, 122};
    uint32_t indexes_3rounds[8] = {4, 52, 34, 35, 65, 82, 85, 102};
    uint32_t indexes_4rounds[16] = {15, 65, 66, 78, 95, 96, 112, 116, 143, 147, 174, 224, 225, 237, 254, 255};
    uint32_t indexes_4rounds[16] = {14, 15, 18, 35, 45, 46, 48, 62, 63, 65, 76, 93, 95, 112, 113, 125};*/
    uint32_t indexes_5rounds[32] = {137, 138, 140, 154, 155, 157, 168, 185, 187, 204, 205, 217, 234, 235, 238, 255, 272, 282, 283, 285, 299, 300, 302, 313, 330, 332, 349, 345, 362, 379, 380, 383};
    testDegree( indexes_5rounds, 2, 5, 0 );

    //test_fast_round_bare();

    return 1;
}