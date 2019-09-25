#include "trail_diff.h"
#include "trail_lin.h"

int main()
{
    /*
    ** Some sanity checks
    */
    //sanityTestLambda();
    //sanityTestDiffWeight();
    //sanityTestLambdaTransposed();
    //sanityTestCorrWeight();

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

    return 1;
}