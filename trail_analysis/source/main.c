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

    /*
    ** Extending the optimal differential trail on 4 rounds to 6 rounds
    */ 
    /*Trail trail;
    State state;
    diffTrailSearchStart( &trail, 29, 4 );
    copyState( &trail.state[STATESIZE * 3], state );
    diffTrailExtend( state, 59, 2 );*/

    /*
    ** Looking from optimal differential trails starting from 1-bit differences
    */
    Trail trail;
    // 1 round
    linTrailSearchStart( &trail, 2, 1 );
    // 2 rounds
    //linTrailSearchStart( &trail, 4, 2 );
    // 3 rounds
    //linTrailSearchStart( &trail, 10, 3 );
    // 4 rounds
    //linTrailSearchStart( &trail, 20, 4 );
    // 5 rounds
    //linTrailSearchStart( &trail, 34, 5 );

    /*
    ** Extending the optimal differential trail on 5 rounds to 6 rounds
    */ 
    /*State state = {0x00004001, 0x00000000, 0x40014000, 0x80008000, 
                    0x00000000, 0x00000000, 0x40010000, 0x80000000,
                    0x00008000, 0x00000000, 0x40018000, 0x80010001};
    linTrailExtend( state, 34, 78, 2 );*/

    return 1;
}