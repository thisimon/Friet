/**
 Implementation by Pedro Maat C. Massolino,
 hereby denoted as "the implementer".

 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
*/
module friet_permutation_rc(rc, new_rc);

input [4:0] rc;
output [4:0] new_rc;

assign new_rc[0] = rc[0] ^ rc[3];
assign new_rc[1] = rc[0];
assign new_rc[2] = rc[1];
assign new_rc[3] = rc[2];
assign new_rc[4] = ~rc[4];

endmodule