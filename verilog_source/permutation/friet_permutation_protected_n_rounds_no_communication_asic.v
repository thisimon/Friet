/**
 Implementation by Pedro Maat C. Massolino,
 hereby denoted as "the implementer".

 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
*/
module friet_permutation_protected_n_rounds_no_communication(clk, aresetn, start_enable, state_buffer_in_enabled, state_buffer_in, state_buffer_out_enabled, state_buffer, core_free, core_finish, fault_detected);

parameter BUFFER_LENGTH = 32;
parameter COMBINATIONAL_ROUNDS = 1;

input clk;
input aresetn;
input start_enable;
input state_buffer_in_enabled;
input [(BUFFER_LENGTH - 1):0] state_buffer_in;
input state_buffer_out_enabled;
output [383:0] state_buffer;
output core_free;
output core_finish;
output fault_detected;

(* keep *) wire [127:0] permutation_a [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] permutation_b [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] permutation_c [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] permutation_d [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] permutation_new_a [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] permutation_new_b [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] permutation_new_c [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] permutation_new_d [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [4:0]  permutation_rc_c [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [4:0]  permutation_rc_d [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [4:0]  permutation_new_rc_c [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [4:0]  permutation_new_rc_d [(COMBINATIONAL_ROUNDS - 1) : 0];

(* keep *) wire [127:0] parity_buffer_masked;
(* keep *) wire [127:0] computed_parity;

reg is_last_rc;

localparam [4:0] master_round_constant  = 5'b01111;
localparam [4:0] last_round_constant_23 = 5'b11001;
localparam [4:0] last_round_constant_22 = 5'b01100;
localparam [4:0] last_round_constant_21 = 5'b10110;
localparam [4:0] last_round_constant_20 = 5'b01011;
localparam [4:0] last_round_constant_18 = 5'b01010;
localparam [4:0] last_round_constant_16 = 5'b01110;
localparam [4:0] last_round_constant_12 = 5'b00001;
localparam [4:0] last_round_constant_0  = 5'b01111;

reg internal_core_free;
reg internal_finish;
(* keep *) reg internal_fault_detected;
(* keep *) reg internal_new_fault_detected;

reg [383:0] input_output_buffer;
(* keep *) reg [127:0] parity_buffer;
(* keep *) reg [4:0] round_constant_c_buffer;
(* keep *) reg [4:0] round_constant_d_buffer;

assign permutation_a[0]  = input_output_buffer[127:0];
assign permutation_b[0]  = input_output_buffer[255:128];
assign permutation_c[0]  = input_output_buffer[383:256];
assign permutation_d[0]  = parity_buffer;
assign permutation_rc_c[0] = round_constant_c_buffer;
assign permutation_rc_d[0] = round_constant_d_buffer;

generate
    genvar gen_j;
    for (gen_j = 0; gen_j < COMBINATIONAL_ROUNDS; gen_j = gen_j + 1) begin: all_combinational_rounds
        (* keep_hierarchy *)
        friet_permutation_protected_round  permutation_gen_j(
            .a(permutation_a[gen_j]),
            .b(permutation_b[gen_j]),
            .c(permutation_c[gen_j]),
            .d(permutation_d[gen_j]),
            .rc_c(permutation_rc_c[gen_j]),
            .rc_d(permutation_rc_d[gen_j]),
            .new_a(permutation_new_a[gen_j]),
            .new_b(permutation_new_b[gen_j]),
            .new_c(permutation_new_c[gen_j]),
            .new_d(permutation_new_d[gen_j])
            );
            
        (* keep_hierarchy *)
        friet_permutation_rc rc_c_gen_j(
            .rc(permutation_rc_c[gen_j]),
            .new_rc(permutation_new_rc_c[gen_j])
        );
        (* keep_hierarchy *)
        friet_permutation_rc rc_d_gen_j(
            .rc(permutation_rc_d[gen_j]),
            .new_rc(permutation_new_rc_d[gen_j])
        );
        
        if(gen_j > 0) begin: all_combinational_rounds_next_iteration
            assign permutation_a[gen_j]  = permutation_new_a[gen_j-1];
            assign permutation_b[gen_j]  = permutation_new_b[gen_j-1];
            assign permutation_c[gen_j]  = permutation_new_c[gen_j-1];
            assign permutation_d[gen_j]  = permutation_new_d[gen_j-1];
            assign permutation_rc_c[gen_j] = permutation_new_rc_c[gen_j-1];
            assign permutation_rc_d[gen_j] = permutation_new_rc_d[gen_j-1];
        end
    end
endgenerate

always @(posedge clk) begin
    if(internal_core_free == 1'b0) begin
        input_output_buffer <= {permutation_new_c[COMBINATIONAL_ROUNDS - 1], permutation_new_b[COMBINATIONAL_ROUNDS - 1], permutation_new_a[COMBINATIONAL_ROUNDS - 1]};
        parity_buffer <= permutation_new_d[COMBINATIONAL_ROUNDS - 1];
    end else if(start_enable == 1'b1) begin
        parity_buffer <= computed_parity;
    end else if(state_buffer_in_enabled == 1'b1) begin
        input_output_buffer <= {state_buffer_in, input_output_buffer[383:BUFFER_LENGTH]};
    end else if(state_buffer_out_enabled == 1'b1) begin
        input_output_buffer <= {input_output_buffer[(BUFFER_LENGTH-1):0], input_output_buffer[383:BUFFER_LENGTH]};
    end
end

always @(posedge clk or negedge aresetn) begin
    if (!aresetn) begin
        internal_core_free <= 1'b1;
        internal_finish <= 1'b0;
        round_constant_c_buffer <= master_round_constant;
        round_constant_d_buffer <= master_round_constant;
        internal_fault_detected <= 1'b0;
    end else begin
        if(internal_core_free == 1'b1) begin
            internal_finish <= 1'b0;
            if(start_enable == 1'b1) begin
                internal_core_free <= 1'b0;
                round_constant_c_buffer <= master_round_constant;
                round_constant_d_buffer <= master_round_constant;
                internal_fault_detected <= 1'b0;
            end
        end else if(is_last_rc == 1'b1) begin
            internal_core_free <= 1'b1;
            internal_finish <= 1'b1;
        end else begin
            round_constant_c_buffer <= permutation_new_rc_c[COMBINATIONAL_ROUNDS - 1];
            round_constant_d_buffer <= permutation_new_rc_d[COMBINATIONAL_ROUNDS - 1];
            internal_fault_detected <= internal_fault_detected | internal_new_fault_detected;
        end
    end
end

generate
    if(COMBINATIONAL_ROUNDS == 1) begin: last_round_for_1_round
        always @(*) begin
            if(permutation_rc_c[0] == last_round_constant_23) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 2) begin: last_round_for_2_rounds
        always @(*) begin
            if(permutation_rc_c[0] == last_round_constant_22) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 3) begin: last_round_for_3_rounds
        always @(*) begin
            if(permutation_rc_c[0] == last_round_constant_21) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 4) begin: last_round_for_4_rounds
        always @(*) begin
            if(permutation_rc_c[0] == last_round_constant_20) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 6) begin: last_round_for_6_rounds
        always @(*) begin
            if(permutation_rc_c[0] == last_round_constant_18) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 8) begin: last_round_for_8_rounds
        always @(*) begin
            if(permutation_rc_c[0] == last_round_constant_16) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 12) begin: last_round_for_12_rounds
        always @(*) begin
            if(permutation_rc_c[0] == last_round_constant_12) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 24) begin: last_round_for_24_rounds
        always @(*) begin
            if(permutation_rc_c[0] == last_round_constant_0) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
        
    end
endgenerate

always @(*) begin
    if(computed_parity != 128'b0) begin
        internal_new_fault_detected = 1'b1;
    end else begin                     
        internal_new_fault_detected = 1'b0;
    end
end

generate
    for (gen_j = 0; gen_j < 128; gen_j = gen_j + 1) begin: all_parity_bits
        (* keep_hierarchy *) and PARITY_AND_MASK(parity_buffer_masked[gen_j], parity_buffer[gen_j], ~internal_core_free);
        (* keep_hierarchy *) xor PARITY_XOR(computed_parity[gen_j], input_output_buffer[gen_j], input_output_buffer[gen_j+128], input_output_buffer[gen_j+256], parity_buffer_masked[gen_j]);
    end
endgenerate

assign state_buffer   = input_output_buffer;
assign core_free      = internal_core_free;
assign core_finish    = internal_finish;
assign fault_detected = internal_fault_detected;

endmodule