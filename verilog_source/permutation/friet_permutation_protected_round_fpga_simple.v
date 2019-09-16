/**
 Implementation by Pedro Maat C. Massolino,
 hereby denoted as "the implementer".

 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
*/
(* dont_touch = "yes" *) module friet_permutation_protected_round(a, b, c, d, rc_c, rc_d, new_a, new_b, new_c, new_d);

input [127:0] a;
input [127:0] b;
input [127:0] c;
input [127:0] d;
input [4:0] rc_c;
input [4:0] rc_d;
output [127:0] new_a;
output [127:0] new_b;
output [127:0] new_c;
output [127:0] new_d;

wire [127:0] temp_a;
wire [127:0] temp_b;
wire [127:0] temp_c;
wire [127:0] temp_d;

(* dont_touch = "yes" *) wire [127:0] temp_first_mix_1;
(* dont_touch = "yes" *) wire [127:0] temp_first_mix_2;
(* dont_touch = "yes" *) wire [127:0] temp_second_mix_1;
(* dont_touch = "yes" *) wire [127:0] temp_second_mix_2;
(* dont_touch = "yes" *) wire [127:0] temp_non_linear_1;
(* dont_touch = "yes" *) wire [127:0] temp_non_linear_2;

assign temp_a = a;
assign temp_b = b;
assign temp_c[3:1]    = c[3:1];
assign temp_c[7:5]    = c[7:5];
assign temp_c[11:9]   = c[11:9];
assign temp_c[15:13]  = c[15:13];
assign temp_c[19:17]  = c[19:17];
assign temp_c[23:21]  = c[23:21];
assign temp_c[27:25]  = c[27:25];
assign temp_c[127:29] = c[127:29];
assign temp_d[3:1]    = d[3:1];
assign temp_d[7:5]    = d[7:5];
assign temp_d[11:9]   = d[11:9];
assign temp_d[15:13]  = d[15:13];
assign temp_d[19:17]  = d[19:17];
assign temp_d[23:21]  = d[23:21];
assign temp_d[27:25]  = d[27:25];
assign temp_d[127:29] = d[127:29];

generate
    genvar gen_j;
    for (gen_j = 0; gen_j < 4; gen_j = gen_j + 1) begin: c_d_with_rc
        (* dont_touch = "yes" *) assign temp_c[4*gen_j]    = c[4*gen_j] ^ (rc_c[gen_j] & (~rc_c[4]));
        (* dont_touch = "yes" *) assign temp_c[4*gen_j+16] = c[4*gen_j+16] ^ (rc_c[gen_j] & rc_c[4]);
        (* dont_touch = "yes" *) assign temp_d[4*gen_j]    = d[4*gen_j] ^ (rc_d[gen_j] & (~rc_d[4]));
        (* dont_touch = "yes" *) assign temp_d[4*gen_j+16] = d[4*gen_j+16] ^ (rc_d[gen_j] & rc_d[4]);
    end
endgenerate

// First mixing step

(* dont_touch = "yes" *) assign temp_first_mix_1[0] = temp_a[127] ^ temp_c[0];
(* dont_touch = "yes" *) assign temp_first_mix_2[0] = temp_a[127] ^ temp_b[0];

generate
    for (gen_j = 1; gen_j < 128; gen_j = gen_j + 1) begin: first_mix_1_2
        (* dont_touch = "yes" *) assign temp_first_mix_1[gen_j] = temp_a[gen_j-1] ^ temp_c[gen_j];
        (* dont_touch = "yes" *) assign temp_first_mix_2[gen_j] = temp_a[gen_j-1] ^ temp_b[gen_j];
    end
endgenerate

// Second mixing step

generate
    for (gen_j = 0; gen_j < 80; gen_j = gen_j + 1) begin: second_mix_1_2_79
        (* dont_touch = "yes" *) assign temp_second_mix_1[gen_j] = temp_first_mix_1[gen_j+48] ^ temp_a[gen_j];
        (* dont_touch = "yes" *) assign temp_second_mix_2[gen_j] = temp_first_mix_1[gen_j+48] ^ temp_first_mix_2[gen_j];
    end
    for (gen_j = 80; gen_j < 128; gen_j = gen_j + 1) begin: second_mix_1_2_127
        (* dont_touch = "yes" *) assign temp_second_mix_1[gen_j] = temp_first_mix_1[gen_j-80] ^ temp_a[gen_j];
        (* dont_touch = "yes" *) assign temp_second_mix_2[gen_j] = temp_first_mix_1[gen_j-80] ^ temp_first_mix_2[gen_j];
    end
endgenerate

// Non linear step

generate
    for (gen_j = 0; gen_j < 36; gen_j = gen_j + 1) begin: non_linear_1_2_35
        (* dont_touch = "yes" *) assign temp_non_linear_1[gen_j] = (temp_second_mix_1[gen_j+61] & temp_second_mix_2[gen_j+92]) ^ temp_d[gen_j];
        (* dont_touch = "yes" *) assign temp_non_linear_2[gen_j] = (temp_second_mix_1[gen_j+61] & temp_second_mix_2[gen_j+92]) ^ temp_first_mix_1[gen_j];
    end
    for (gen_j = 36; gen_j < 67; gen_j = gen_j + 1) begin: non_linear_1_2_66
        (* dont_touch = "yes" *) assign temp_non_linear_1[gen_j] = (temp_second_mix_1[gen_j+61] & temp_second_mix_2[gen_j-36]) ^ temp_d[gen_j];
        (* dont_touch = "yes" *) assign temp_non_linear_2[gen_j] = (temp_second_mix_1[gen_j+61] & temp_second_mix_2[gen_j-36]) ^ temp_first_mix_1[gen_j];
    end
    for (gen_j = 67; gen_j < 128; gen_j = gen_j + 1) begin: non_linear_1_2_127
        (* dont_touch = "yes" *) assign temp_non_linear_1[gen_j] = (temp_second_mix_1[gen_j-67] & temp_second_mix_2[gen_j-36]) ^ temp_d[gen_j];
        (* dont_touch = "yes" *) assign temp_non_linear_2[gen_j] = (temp_second_mix_1[gen_j-67] & temp_second_mix_2[gen_j-36]) ^ temp_first_mix_1[gen_j];
    end
endgenerate

assign new_a = temp_non_linear_1;
assign new_b = temp_second_mix_2;
assign new_c = temp_second_mix_1;
assign new_d = temp_non_linear_2;

endmodule