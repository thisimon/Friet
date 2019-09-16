/**
 Implementation by Pedro Maat C. Massolino,
 hereby denoted as "the implementer".

 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
*/
module friet_permutation_round (a, b, c, rc, new_a, new_b, new_c);

input [127:0] a;
input [127:0] b;
input [127:0] c;
input [4:0] rc;
output [127:0] new_a;
output [127:0] new_b;
output [127:0] new_c;

wire [127:0] temp_a;
wire [127:0] temp_b;
wire [127:0] temp_c;

wire [127:0] temp_t;
wire [127:0] temp_first_mix;

wire [127:0] temp_new_a;
wire [127:0] temp_new_b;
wire [127:0] temp_new_c;

assign temp_a = a;
assign temp_b = b;
 
assign temp_c[0]  = c[0]  ^ (rc[0] & (~rc[4]));
assign temp_c[4]  = c[4]  ^ (rc[1] & (~rc[4]));
assign temp_c[8]  = c[8]  ^ (rc[2] & (~rc[4]));
assign temp_c[12] = c[12] ^ (rc[3] & (~rc[4]));
assign temp_c[16] = c[16] ^ (rc[0] & rc[4]);
assign temp_c[20] = c[20] ^ (rc[1] & rc[4]);
assign temp_c[24] = c[24] ^ (rc[2] & rc[4]);
assign temp_c[28] = c[28] ^ (rc[3] & rc[4]);
assign temp_c[3:1]    = c[3:1];
assign temp_c[7:5]    = c[7:5];
assign temp_c[11:9]   = c[11:9];
assign temp_c[15:13]  = c[15:13];
assign temp_c[19:17]  = c[19:17];
assign temp_c[23:21]  = c[23:21];
assign temp_c[27:25]  = c[27:25];
assign temp_c[127:29] = c[127:29];

assign temp_t = temp_a ^ temp_b ^ temp_c;

// First mixing step

assign temp_first_mix[0]     = temp_a[127]   ^ temp_c[0];
assign temp_first_mix[127:1] = temp_a[126:0] ^ temp_c[127:1];

// Second mixing step

assign temp_new_c[79:0]   = temp_first_mix[127:48] ^ temp_a[79:0];
assign temp_new_c[127:80] = temp_first_mix[47:0]   ^ temp_a[127:80];

assign temp_new_b = temp_new_c ^ temp_first_mix ^ temp_t;

// Non linear step

assign temp_new_a[35:0]   = (temp_new_c[96:61]  & temp_new_b[127:92]) ^ temp_t[35:0];
assign temp_new_a[66:36]  = (temp_new_c[127:97] & temp_new_b[30:0])   ^ temp_t[66:36];
assign temp_new_a[127:67] = (temp_new_c[60:0]   & temp_new_b[91:31])  ^ temp_t[127:67];

assign new_a = temp_new_a;
assign new_b = temp_new_b;
assign new_c = temp_new_c;

endmodule