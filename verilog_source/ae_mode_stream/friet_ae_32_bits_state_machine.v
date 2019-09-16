/**
 Implementation by Pedro Maat C. Massolino,
 hereby denoted as "the implementer".

 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
*/
module friet_ae_32_bits_state_machine(clk, arstn, din, din_valid, dout_ready, din_ready, is_din_less_than_four, is_ctr_data_size_zero, is_ctr_data_size_four, is_ctr_data_size_four_five_six_seven, is_ctr_data_size_less_than_four, is_ctr_data_size_start_zero, ctr_data_size_enable, ctr_data_size_load, is_ctr_data_duplex_one, is_ctr_data_duplex_zero, ctr_data_duplex_start, ctr_data_duplex_enable, ctr_data_duplex_force_valid, permutation_force_din_valid, permutation_din_type, permutation_din_padded_force_size_zero, permutation_state_reset, permutation_state_mode_duplex, permutation_state_mode_new_round, permutation_state_din_direct_din, is_last_rc, permutation_rc_enable, permutation_rc_start, accumulated_tag_difference_reset, tag_accumulated_tag_out, receiving_data, tag_generation_mode, tag_verification_mode);

input clk;
input arstn;
input[31:0] din;
input din_valid;
input dout_ready;
output din_ready;

input is_din_less_than_four;
input is_ctr_data_size_zero;
input is_ctr_data_size_four;
input is_ctr_data_size_four_five_six_seven;
input is_ctr_data_size_less_than_four;
input is_ctr_data_size_start_zero;
output ctr_data_size_enable;
output ctr_data_size_load;

input is_ctr_data_duplex_zero;
input is_ctr_data_duplex_one;
output ctr_data_duplex_start;
output ctr_data_duplex_enable;
output ctr_data_duplex_force_valid;

output permutation_force_din_valid;
output [1:0] permutation_din_type;
output permutation_din_padded_force_size_zero;
output permutation_state_reset;
output permutation_state_mode_duplex;
output permutation_state_mode_new_round;
output permutation_state_din_direct_din;

input is_last_rc;
output permutation_rc_enable;
output permutation_rc_start;

output accumulated_tag_difference_reset;
output tag_accumulated_tag_out;

output receiving_data;
output tag_generation_mode;
output tag_verification_mode;

reg r_din_ready;
reg r_ctr_data_size_enable;
reg r_ctr_data_size_load;
reg r_ctr_data_duplex_start;
reg r_ctr_data_duplex_enable;
reg r_ctr_data_duplex_force_valid;
reg r_permutation_force_din_valid;
reg [1:0] r_permutation_din_type;
reg r_permutation_din_padded_force_size_zero;
reg r_permutation_state_reset;
reg r_permutation_state_mode_duplex;
reg r_permutation_state_mode_new_round;
reg r_permutation_state_din_direct_din;
reg r_permutation_rc_enable;
reg r_permutation_rc_start;
reg r_accumulated_tag_difference_reset;
reg r_tag_accumulated_tag_out;
reg r_receiving_data;
reg r_tag_generation_mode;
reg r_tag_verification_mode;

localparam s_reset = 7'b0000000, s_wait_command = 7'b0000001,
s_duplex_empty_0 = 7'b0010000, s_duplex_empty_2 = 7'b0010010, s_duplex_empty_3 = 7'b0010011, s_duplex_empty_4 = 7'b0010100, s_duplex_empty_5 = 7'b0010101, s_duplex_empty_6 = 7'b0010110, s_duplex_empty_7 = 7'b0010111, s_duplex_empty_8 = 7'b0011000,
s_duplex_empty_9 = 7'b0011001, s_duplex_empty_10 = 7'b0011010, s_duplex_empty_6b = 7'b0011011, s_duplex_empty_9b = 7'b0011100,
s_duplex_enc_0 = 7'b0100000, s_duplex_enc_2 = 7'b0100010, s_duplex_enc_3 = 7'b0100011, s_duplex_enc_4 = 7'b0100100, s_duplex_enc_5 = 7'b0100101, s_duplex_enc_6 = 7'b0100110, s_duplex_enc_7 = 7'b0100111, s_duplex_enc_8 = 7'b0101000,
s_duplex_enc_9 = 7'b0101001, s_duplex_enc_10 = 7'b0101010, s_duplex_enc_6b = 7'b0101011, s_duplex_enc_9b = 7'b0101100,
s_duplex_dec_0 = 7'b0110000, s_duplex_dec_2 = 7'b0110010, s_duplex_dec_3 = 7'b0110011, s_duplex_dec_4 = 7'b0110100, s_duplex_dec_5 = 7'b0110101, s_duplex_dec_6 = 7'b0110110, s_duplex_dec_7 = 7'b0110111, s_duplex_dec_8 = 7'b0111000,
s_duplex_dec_9 = 7'b0111001, s_duplex_dec_10 = 7'b0111010, s_duplex_dec_6b = 7'b0111011, s_duplex_dec_9b = 7'b0111100,
s_duplex_gtag_0 = 7'b1000000, s_duplex_gtag_2 = 7'b1000010, s_duplex_gtag_3 = 7'b1000011, s_duplex_gtag_4 = 7'b1000100, s_duplex_gtag_5 = 7'b1000101, s_duplex_gtag_6 = 7'b1000110, s_duplex_gtag_7 = 7'b1000111, s_duplex_gtag_8 = 7'b1001000,
s_duplex_vtag_0 = 7'b1010000, s_duplex_vtag_2 = 7'b1010010, s_duplex_vtag_3 = 7'b1010011, s_duplex_vtag_4 = 7'b1010100, s_duplex_vtag_5 = 7'b1010101, s_duplex_vtag_6 = 7'b1010110, s_duplex_vtag_7 = 7'b1010111, s_duplex_vtag_8 = 7'b1011000;
reg[6:0] actual_state, next_state;

always @(posedge clk or negedge arstn) begin
    if (arstn == 1'b0) begin
        actual_state <= s_reset;
    end
    else begin
        actual_state <= next_state;
    end
end

// Choose the output based on the state
always @(*) begin
    case(actual_state)
        s_reset : begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b1;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_wait_command: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        
        s_duplex_empty_0: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b1;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_empty_2: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b11;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_empty_3: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b11;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_empty_4: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b01;
            r_permutation_din_padded_force_size_zero = 1'b1;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_empty_5: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b1;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_empty_6: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b10;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_empty_6b: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b10;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_empty_7: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b1;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_empty_8: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b1;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_empty_9: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b10;
            r_permutation_din_padded_force_size_zero = 1'b1;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_empty_9b: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b10;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_empty_10: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        
        
        s_duplex_enc_0: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b1;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_enc_2: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b11;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_enc_3: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b11;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_enc_4: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b10;
            r_permutation_din_padded_force_size_zero = 1'b1;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_enc_5: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b1;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_enc_6: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b01;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_enc_6b: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b01;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_enc_7: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b1;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_enc_8: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b1;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_enc_9: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b01;
            r_permutation_din_padded_force_size_zero = 1'b1;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_enc_9b: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b01;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_enc_10: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        
        
        s_duplex_dec_0: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b1;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_dec_2: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b11;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b1;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_dec_3: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b11;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b1;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_dec_4: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b10;
            r_permutation_din_padded_force_size_zero = 1'b1;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_dec_5: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b1;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_dec_6: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b01;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_dec_6b: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b01;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b1;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_dec_7: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b1;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_dec_8: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b1;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_dec_9: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b01;
            r_permutation_din_padded_force_size_zero = 1'b1;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_dec_9b: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b01;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b1;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_dec_10: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        
        
        s_duplex_gtag_0: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b1;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_gtag_2: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b1;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_gtag_3: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b1;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_gtag_4: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b1;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_gtag_5: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b01;
            r_permutation_din_padded_force_size_zero = 1'b1;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_gtag_6: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b1;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_gtag_7: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b1;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_gtag_8: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b1;
            r_tag_verification_mode = 1'b0;
        end
        
        s_duplex_vtag_0: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b1;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b1;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_vtag_2: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b1;
        end
        s_duplex_vtag_3: begin
            r_din_ready = 1'b1;
            r_ctr_data_size_enable = 1'b1;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b1;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b1;
        end
        s_duplex_vtag_4: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b1;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_vtag_5: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b1;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b01;
            r_permutation_din_padded_force_size_zero = 1'b1;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b1;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_vtag_6: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b1;
            r_ctr_data_duplex_force_valid = 1'b1;
            r_permutation_force_din_valid = 1'b1;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b1;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_vtag_7: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b1;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b1;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
        s_duplex_vtag_8: begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b1;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b1;
            r_tag_verification_mode = 1'b1;
        end
        default : begin
            r_din_ready = 1'b0;
            r_ctr_data_size_enable = 1'b0;
            r_ctr_data_size_load = 1'b0;
            r_ctr_data_duplex_start = 1'b0;
            r_ctr_data_duplex_enable = 1'b0;
            r_ctr_data_duplex_force_valid = 1'b0;
            r_permutation_force_din_valid = 1'b0;
            r_permutation_din_type = 2'b00;
            r_permutation_din_padded_force_size_zero = 1'b0;
            r_permutation_state_reset = 1'b0;
            r_permutation_state_mode_duplex = 1'b0;
            r_permutation_state_mode_new_round = 1'b0;
            r_permutation_state_din_direct_din = 1'b0;
            r_permutation_rc_enable = 1'b0;
            r_permutation_rc_start = 1'b0;
            r_accumulated_tag_difference_reset = 1'b0;
            r_tag_accumulated_tag_out = 1'b0;
            r_receiving_data = 1'b0;
            r_tag_generation_mode = 1'b0;
            r_tag_verification_mode = 1'b0;
        end
    endcase
end

// Choose the next state based on the actual state and input
always @(*) begin
    case(actual_state)
        s_reset : begin
            next_state = s_wait_command;
        end
        s_wait_command: begin
            if(din_valid == 1'b1) begin
                case(din[7:0])
                    8'h00: begin
                        next_state = s_reset;
                    end
                    8'h01: begin
                        next_state = s_duplex_empty_0;
                    end
                    8'h02: begin
                        next_state = s_duplex_enc_0;
                    end
                    8'h03: begin
                        next_state = s_duplex_dec_0;
                    end
                    8'h04: begin
                        next_state = s_duplex_gtag_0;
                    end
                    8'h05: begin
                        next_state = s_duplex_vtag_0;
                    end
                    default: begin
                        next_state = s_wait_command;
                    end
                endcase
            end else begin
                next_state = s_wait_command;
            end
        end
        
        s_duplex_empty_0: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_size_start_zero == 1'b1) begin
                    next_state = s_duplex_empty_9;
                end else if(is_din_less_than_four == 1'b1) begin
                    next_state = s_duplex_empty_9b;
                end else begin
                    next_state = s_duplex_empty_2;
                end
            end else begin
                next_state = s_duplex_empty_0;
            end
        end
        s_duplex_empty_2: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_size_four == 1'b1) begin
                    next_state = s_duplex_empty_6;
                end else if(is_ctr_data_size_four_five_six_seven == 1'b1) begin
                    next_state = s_duplex_empty_6b;
                end else begin
                    next_state = s_duplex_empty_3;
                end
            end else begin
                next_state = s_duplex_empty_2;
            end
        end
        s_duplex_empty_3: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_size_four == 1'b1) begin
                    next_state = s_duplex_empty_6;
                end else if(is_ctr_data_duplex_one == 1'b1) begin
                    next_state = s_duplex_empty_4;
                end else if(is_ctr_data_size_four_five_six_seven == 1'b1) begin
                    next_state = s_duplex_empty_6b;
                end else begin
                    next_state = s_duplex_empty_3;
                end
            end else begin
                next_state = s_duplex_empty_3;
            end
        end
        s_duplex_empty_4: begin
            next_state = s_duplex_empty_5;
        end
        s_duplex_empty_5: begin
            if(is_last_rc == 1'b1) begin
                if(is_ctr_data_size_less_than_four == 1'b1) begin
                    next_state = s_duplex_empty_9b;
                end else begin
                    next_state = s_duplex_empty_2;
                end
            end else begin
                next_state = s_duplex_empty_5;
            end
        end
        s_duplex_empty_6: begin
            if(is_ctr_data_duplex_zero == 1'b1) begin
                next_state = s_duplex_empty_8;
            end else begin
                next_state = s_duplex_empty_7;
            end
        end
        s_duplex_empty_6b: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_duplex_zero == 1'b1) begin
                    next_state = s_duplex_empty_8;
                end else begin
                    next_state = s_duplex_empty_7;
                end
            end else begin
                next_state = s_duplex_empty_6b;
            end
        end
        s_duplex_empty_7: begin
            if(is_ctr_data_duplex_one == 1'b1) begin
                next_state = s_duplex_empty_8;
            end else begin
                next_state = s_duplex_empty_7;
            end
        end
        s_duplex_empty_8: begin
            if(is_last_rc == 1'b1) begin
                next_state = s_wait_command;
            end else begin
                next_state = s_duplex_empty_8;
            end
        end
        s_duplex_empty_9: begin
            next_state = s_duplex_empty_10;
        end
        s_duplex_empty_9b: begin
            if(din_valid == 1'b1) begin
                next_state = s_duplex_empty_10;
            end else begin
                next_state = s_duplex_empty_9b;
            end
        end
        s_duplex_empty_10: begin
            next_state = s_duplex_empty_7;
        end

        
        
        s_duplex_enc_0: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_size_start_zero == 1'b1) begin
                    next_state = s_duplex_enc_9;
                end else if(is_din_less_than_four == 1'b1) begin
                    next_state = s_duplex_enc_9b;
                end else begin
                    next_state = s_duplex_enc_2;
                end
            end else begin
                next_state = s_duplex_enc_0;
            end
        end
        s_duplex_enc_2: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_size_four == 1'b1) begin
                    next_state = s_duplex_enc_6;
                end else if(is_ctr_data_size_four_five_six_seven == 1'b1) begin
                    next_state = s_duplex_enc_6b;
                end else begin
                    next_state = s_duplex_enc_3;
                end
            end else begin
                next_state = s_duplex_enc_2;
            end
        end
        s_duplex_enc_3: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_size_four == 1'b1) begin
                    next_state = s_duplex_enc_6;
                end else if(is_ctr_data_duplex_one == 1'b1) begin
                    next_state = s_duplex_enc_4;
                end else if(is_ctr_data_size_four_five_six_seven == 1'b1) begin
                    next_state = s_duplex_enc_6b;
                end else begin
                    next_state = s_duplex_enc_3;
                end
            end else begin
                next_state = s_duplex_enc_3;
            end
        end
        s_duplex_enc_4: begin
            next_state = s_duplex_enc_5;
        end
        s_duplex_enc_5: begin
            if(is_last_rc == 1'b1) begin
                if(is_ctr_data_size_less_than_four == 1'b1) begin
                    next_state = s_duplex_enc_9b;
                end else begin
                    next_state = s_duplex_enc_2;
                end
            end else begin
                next_state = s_duplex_enc_5;
            end
        end
        s_duplex_enc_6: begin
            if(is_ctr_data_duplex_zero == 1'b1) begin
                next_state = s_duplex_enc_8;
            end else begin
                next_state = s_duplex_enc_7;
            end
        end
        s_duplex_enc_6b: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_duplex_zero == 1'b1) begin
                    next_state = s_duplex_enc_8;
                end else begin
                    next_state = s_duplex_enc_7;
                end
            end else begin
                next_state = s_duplex_enc_6b;
            end
        end
        s_duplex_enc_7: begin
            if(is_ctr_data_duplex_one == 1'b1) begin
                next_state = s_duplex_enc_8;
            end else begin
                next_state = s_duplex_enc_7;
            end
        end
        s_duplex_enc_8: begin
            if(is_last_rc == 1'b1) begin
                next_state = s_wait_command;
            end else begin
                next_state = s_duplex_enc_8;
            end
        end
        s_duplex_enc_9: begin
            next_state = s_duplex_enc_10;
        end
        s_duplex_enc_9b: begin
            if(din_valid == 1'b1) begin
                next_state = s_duplex_enc_10;
            end else begin
                next_state = s_duplex_enc_9b;
            end
        end
        s_duplex_enc_10: begin
            next_state = s_duplex_enc_7;
        end
        
        
        
        s_duplex_dec_0: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_size_start_zero == 1'b1) begin
                    next_state = s_duplex_dec_9;
                end else if(is_din_less_than_four == 1'b1) begin
                    next_state = s_duplex_dec_9b;
                end else begin
                    next_state = s_duplex_dec_2;
                end
            end else begin
                next_state = s_duplex_dec_0;
            end
        end
        s_duplex_dec_2: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_size_four == 1'b1) begin
                    next_state = s_duplex_dec_6;
                end else if(is_ctr_data_size_four_five_six_seven == 1'b1) begin
                    next_state = s_duplex_dec_6b;
                end else begin
                    next_state = s_duplex_dec_3;
                end
            end else begin
                next_state = s_duplex_dec_2;
            end
        end
        s_duplex_dec_3: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_size_four == 1'b1) begin
                    next_state = s_duplex_dec_6;
                end else if(is_ctr_data_duplex_one == 1'b1) begin
                    next_state = s_duplex_dec_4;
                end else if(is_ctr_data_size_four_five_six_seven == 1'b1) begin
                    next_state = s_duplex_dec_6b;
                end else begin
                    next_state = s_duplex_dec_3;
                end
            end else begin
                next_state = s_duplex_dec_3;
            end
        end
        s_duplex_dec_4: begin
            next_state = s_duplex_dec_5;
        end
        s_duplex_dec_5: begin
            if(is_last_rc == 1'b1) begin
                if(is_ctr_data_size_less_than_four == 1'b1) begin
                    next_state = s_duplex_dec_9b;
                end else begin
                    next_state = s_duplex_dec_2;
                end
            end else begin
                next_state = s_duplex_dec_5;
            end
        end
        s_duplex_dec_6: begin
            if(is_ctr_data_duplex_zero == 1'b1) begin
                next_state = s_duplex_dec_8;
            end else begin
                next_state = s_duplex_dec_7;
            end
        end
        s_duplex_dec_6b: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_duplex_zero == 1'b1) begin
                    next_state = s_duplex_dec_8;
                end else begin
                    next_state = s_duplex_dec_7;
                end
            end else begin
                next_state = s_duplex_dec_6b;
            end
        end
        s_duplex_dec_7: begin
            if(is_ctr_data_duplex_one == 1'b1) begin
                next_state = s_duplex_dec_8;
            end else begin
                next_state = s_duplex_dec_7;
            end
        end
        s_duplex_dec_8: begin
            if(is_last_rc == 1'b1) begin
                next_state = s_wait_command;
            end else begin
                next_state = s_duplex_dec_8;
            end
        end
        s_duplex_dec_9: begin
            next_state = s_duplex_dec_10;
        end
        s_duplex_dec_9b: begin
            if(din_valid == 1'b1) begin
                next_state = s_duplex_dec_10;
            end else begin
                next_state = s_duplex_dec_9b;
            end
        end
        s_duplex_dec_10: begin
            next_state = s_duplex_dec_7;
        end
        
        
        s_duplex_gtag_0: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_size_start_zero == 1'b1) begin
                    next_state = s_wait_command;
                end else begin
                    next_state = s_duplex_gtag_2;
                end
            end else begin
                next_state = s_duplex_gtag_0;
            end
        end
        s_duplex_gtag_2: begin
            if(dout_ready == 1'b1) begin
                if((is_ctr_data_size_four == 1'b1) || (is_ctr_data_size_less_than_four == 1'b1)) begin
                    next_state = s_duplex_gtag_4;
                end else begin
                    next_state = s_duplex_gtag_3;
                end
            end else begin
                next_state = s_duplex_gtag_2;
            end
        end
        s_duplex_gtag_3: begin
            if(dout_ready == 1'b1) begin
                if((is_ctr_data_size_four == 1'b1) || (is_ctr_data_size_less_than_four == 1'b1)) begin
                    next_state = s_duplex_gtag_4;
                end else if(is_ctr_data_duplex_one == 1'b1) begin
                    next_state = s_duplex_gtag_4;
                end else begin
                    next_state = s_duplex_gtag_3;
                end
            end else begin
                next_state = s_duplex_gtag_3;
            end
        end
        s_duplex_gtag_4: begin
            if(is_ctr_data_duplex_zero == 1'b1) begin
                next_state = s_duplex_gtag_5;
            end else begin
                next_state = s_duplex_gtag_4;
            end
        end
        s_duplex_gtag_5: begin
            next_state = s_duplex_gtag_6;
        end
        s_duplex_gtag_6: begin
            if(is_ctr_data_duplex_zero == 1'b1) begin
                next_state = s_duplex_gtag_7;
            end else begin
                next_state = s_duplex_gtag_6;
            end
        end
        s_duplex_gtag_7: begin
            if(is_last_rc == 1'b1) begin
                if(is_ctr_data_size_zero == 1'b1) begin
                    next_state = s_wait_command;
                end else begin
                    next_state = s_duplex_gtag_2;
                end
            end else begin
                next_state = s_duplex_gtag_7;
            end
        end
        s_duplex_gtag_8: begin
            if(dout_ready == 1'b1) begin
                next_state = s_duplex_gtag_4;
            end else begin
                next_state = s_duplex_gtag_8;
            end
        end
        
        
        
        s_duplex_vtag_0: begin
            if(din_valid == 1'b1) begin
                if(is_ctr_data_size_start_zero == 1'b1) begin
                    next_state = s_wait_command;
                end else begin
                    next_state = s_duplex_vtag_2;
                end
            end else begin
                next_state = s_duplex_vtag_0;
            end
        end
        s_duplex_vtag_2: begin
            if(din_valid == 1'b1) begin
                if((is_ctr_data_size_four == 1'b1) || (is_ctr_data_size_less_than_four == 1'b1)) begin
                    next_state = s_duplex_vtag_8;
                end else begin
                    next_state = s_duplex_vtag_3;
                end
            end else begin
                next_state = s_duplex_vtag_2;
            end
        end
        s_duplex_vtag_3: begin
            if(din_valid == 1'b1) begin
                if((is_ctr_data_size_four == 1'b1) || (is_ctr_data_size_less_than_four == 1'b1)) begin
                    next_state = s_duplex_vtag_8;
                end else if(is_ctr_data_duplex_one == 1'b1) begin
                    next_state = s_duplex_vtag_4;
                end else begin
                    next_state = s_duplex_vtag_3;
                end
            end else begin
                next_state = s_duplex_vtag_3;
            end
        end
        s_duplex_vtag_4: begin
            if(is_ctr_data_duplex_zero == 1'b1) begin
                next_state = s_duplex_vtag_5;
            end else begin
                next_state = s_duplex_vtag_4;
            end
        end
        s_duplex_vtag_5: begin
            next_state = s_duplex_vtag_6;
        end
        s_duplex_vtag_6: begin
            if(is_ctr_data_duplex_zero == 1'b1) begin
                next_state = s_duplex_vtag_7;
            end else begin
                next_state = s_duplex_vtag_6;
            end
        end
        s_duplex_vtag_7: begin
            if(is_last_rc == 1'b1) begin
                if(is_ctr_data_size_zero == 1'b1) begin
                    next_state = s_wait_command;
                end else begin
                    next_state = s_duplex_vtag_2;
                end
            end else begin
                next_state = s_duplex_vtag_7;
            end
        end
        s_duplex_vtag_8: begin
            if(dout_ready == 1'b1) begin
                next_state = s_duplex_vtag_4;
            end else begin
                next_state = s_duplex_vtag_8;
            end
        end
        default : begin
            next_state = s_reset;
        end
    endcase
end

assign din_ready = r_din_ready;
assign ctr_data_size_enable = r_ctr_data_size_enable;
assign ctr_data_size_load = r_ctr_data_size_load;
assign ctr_data_duplex_start = r_ctr_data_duplex_start;
assign ctr_data_duplex_enable = r_ctr_data_duplex_enable;
assign ctr_data_duplex_force_valid = r_ctr_data_duplex_force_valid;
assign permutation_force_din_valid = r_permutation_force_din_valid;
assign permutation_din_type = r_permutation_din_type;
assign permutation_din_padded_force_size_zero = r_permutation_din_padded_force_size_zero;
assign permutation_state_reset = r_permutation_state_reset;
assign permutation_state_mode_duplex = r_permutation_state_mode_duplex;
assign permutation_state_mode_new_round = r_permutation_state_mode_new_round;
assign permutation_state_din_direct_din = r_permutation_state_din_direct_din;
assign permutation_rc_enable = r_permutation_rc_enable;
assign permutation_rc_start = r_permutation_rc_start;
assign accumulated_tag_difference_reset = r_accumulated_tag_difference_reset;
assign tag_accumulated_tag_out = r_tag_accumulated_tag_out;
assign receiving_data = r_receiving_data;
assign tag_generation_mode = r_tag_generation_mode;
assign tag_verification_mode = r_tag_verification_mode;

endmodule