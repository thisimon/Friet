#include "trail_diff.h"

int main()
{
    /*
    ** Some sanity checks
    */
    //sanityTestLambda();
    sanityTestLambdaTransposed();
    //sanityTestDiffWeight();

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
    int i;
    diffTrailSearchStart( &trail, 29, 4 );
    copyState( &trail.state[STATESIZE * 3], state );
    diffTrailExtend( state, 59, 2 );*/

    return 1;
}