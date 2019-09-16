/**
 Implementation by Pedro Maat C. Massolino,
 hereby denoted as "the implementer".

 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
*/
module friet_xaon_gate(o, a, b, c);

input a;
input b;
input c;
output o;

assign o = (a&b)^c;

endmodule