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

(* dont_touch = "yes" *) wire [127:0] temp_before_epsilon_a;
(* dont_touch = "yes" *) wire [127:0] temp_before_epsilon_b;
(* dont_touch = "yes" *) wire [127:0] temp_before_epsilon_c;
(* dont_touch = "yes" *) wire [127:0] temp_before_epsilon_d;

generate
    genvar gen_j;
    for (gen_j = 0; gen_j < 128; gen_j = gen_j + 1) begin: before_epsilon
        if((gen_j == 80) || (gen_j == 84) || (gen_j == 88) || (gen_j == 92)) begin: before_epsilon_with_rc_1
            (* dont_touch = "yes" *) assign temp_before_epsilon_a[gen_j] = a[gen_j] ^ (c[(gen_j-80+128) % 128] ^ (rc_c[((gen_j-80) / 4)] & (~rc_c[4])) ^ a[(gen_j-80-1+128) % 128]);
            (* dont_touch = "yes" *) assign temp_before_epsilon_b[gen_j] = b[gen_j] ^ (a[(gen_j-1+128) % 128]) ^ (c[(gen_j-80+128) % 128] ^ (rc_c[((gen_j-80) / 4)] & (~rc_c[4])) ^ a[(gen_j-80-1+128) % 128]);
            (* dont_touch = "yes" *) assign temp_before_epsilon_c[(gen_j-80+128) % 128] = (c[(gen_j-80+128) % 128] ^ (rc_c[((gen_j-80) / 4)] & (~rc_c[4])) ^ a[(gen_j-80-1+128) % 128]);
            (* dont_touch = "yes" *) assign temp_before_epsilon_d[(gen_j-80+128) % 128] = d[(gen_j-80+128) % 128] ^ (rc_d[((gen_j-80) / 4)] & (~rc_d[4]));
        end else if((gen_j == 96) || (gen_j == 100) || (gen_j == 104) || (gen_j == 108)) begin: before_epsilon_with_rc_2
            (* dont_touch = "yes" *) assign temp_before_epsilon_a[gen_j] = a[gen_j] ^ (c[(gen_j-80+128) % 128] ^ (rc_c[((gen_j-96) / 4)] & (rc_c[4])) ^ a[(gen_j-80-1+128) % 128]);
            (* dont_touch = "yes" *) assign temp_before_epsilon_b[gen_j] = b[gen_j] ^ (a[(gen_j-1+128) % 128]) ^ (c[(gen_j-80+128) % 128] ^ (rc_c[((gen_j-96) / 4)] & (rc_c[4])) ^ a[(gen_j-80-1+128) % 128]);
            (* dont_touch = "yes" *) assign temp_before_epsilon_c[(gen_j-80+128) % 128] = (c[(gen_j-80+128) % 128] ^ (rc_c[((gen_j-96) / 4)] & (rc_c[4])) ^ a[(gen_j-80-1+128) % 128]);
            (* dont_touch = "yes" *) assign temp_before_epsilon_d[(gen_j-80+128) % 128] = d[(gen_j-80+128) % 128] ^ (rc_d[((gen_j-96) / 4)] & (rc_d[4]));
        end else begin: before_epsilon_without_rc
            (* dont_touch = "yes" *) assign temp_before_epsilon_a[gen_j] = a[gen_j] ^ (c[(gen_j-80+128) % 128] ^ a[(gen_j-80-1+128) % 128]);
            (* dont_touch = "yes" *) assign temp_before_epsilon_b[gen_j] = b[gen_j] ^ (a[(gen_j-1+128) % 128]) ^ (c[(gen_j-80+128) % 128] ^ a[(gen_j-80-1+128) % 128]);
            (* dont_touch = "yes" *) assign temp_before_epsilon_c[(gen_j-80+128) % 128] = (c[(gen_j-80+128) % 128] ^ a[(gen_j-80-1+128) % 128]);
            (* dont_touch = "yes" *) assign temp_before_epsilon_d[(gen_j-80+128) % 128] = d[(gen_j-80+128) % 128];
        end
    end
endgenerate

generate
    for (gen_j = 0; gen_j < 128; gen_j = gen_j + 1) begin: after_epsilon
        (* dont_touch = "yes" *) assign new_a[gen_j] = temp_before_epsilon_d[gen_j] ^ (temp_before_epsilon_a[(gen_j-67+128) % 128] & temp_before_epsilon_b[(gen_j-36+128) % 128]);
        (* dont_touch = "yes" *) assign new_b[gen_j] = temp_before_epsilon_b[gen_j];
        (* dont_touch = "yes" *) assign new_c[gen_j] = temp_before_epsilon_a[gen_j];
        (* dont_touch = "yes" *) assign new_d[gen_j] = temp_before_epsilon_c[gen_j] ^ (temp_before_epsilon_a[(gen_j-67+128) % 128] & temp_before_epsilon_b[(gen_j-36+128) % 128]);
    end
endgenerate

endmodule