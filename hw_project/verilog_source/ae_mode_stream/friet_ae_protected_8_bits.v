/**
 Implementation by Pedro Maat C. Massolino,
 hereby denoted as "the implementer".

 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
*/
module friet_ae_protected_8_bits(clk, arstn, din, din_valid, din_ready, dout, dout_valid, dout_ready, fault_detected);

parameter COMBINATIONAL_ROUNDS = 1;

input clk;
input arstn;
input [7:0] din;
input din_valid;
output din_ready;
output [7:0] dout;
output dout_valid;
input dout_ready;
output fault_detected;

reg is_din_zero;
wire is_ctr_data_size_start_zero;

reg [31:0] ctr_data_size;
wire ctr_data_size_enable;
wire ctr_data_size_load;
wire [31:0] new_ctr_data_size;
reg is_ctr_data_size_zero;
reg is_ctr_data_size_one;

reg [3:0] ctr_data_duplex;
wire ctr_data_duplex_start;
wire ctr_data_duplex_start_value;
wire ctr_data_duplex_enable;
wire ctr_data_duplex_force_valid;
wire ctr_data_duplex_ctr_valid;
wire [3:0] new_ctr_data_duplex;
reg is_ctr_data_duplex_zero;
reg is_ctr_data_duplex_one;

reg [7:0] permutation_din;
wire permutation_din_valid;
wire permutation_force_din_valid;
wire [1:0] permutation_din_type;
wire [7:0] permutation_din_xor_state;

wire permutation_state_reset;
wire permutation_state_mode_duplex;
wire permutation_state_mode_new_round;
reg [383:0] permutation_state;
wire [383:0] permutation_state_one_round;
(* keep *) reg [127:0] permutation_state_parity;

(* keep *) wire [7:0] permutation_state_parity_direct_din;
(* keep *) wire [7:0] permutation_state_parity_din;
(* keep *) wire [119:0] permutation_state_parity_shift;

(* keep *) wire [127:0] friet_permutation_state_a [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] friet_permutation_state_b [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] friet_permutation_state_c [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] friet_permutation_state_d [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] friet_permutation_state_new_a [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] friet_permutation_state_new_b [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] friet_permutation_state_new_c [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [127:0] friet_permutation_state_new_d [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [4:0] friet_permutation_rc_c [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [4:0] friet_permutation_rc_d [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [4:0] frit_permutation_new_rc_c [(COMBINATIONAL_ROUNDS - 1) : 0];
(* keep *) wire [4:0] frit_permutation_new_rc_d [(COMBINATIONAL_ROUNDS - 1) : 0];

(* keep *) wire [127:0] computed_parity;

(* keep *) reg internal_fault_detected;
(* keep *) reg internal_new_fault_detected;

localparam [4:0] master_round_constant = 5'b01111;
localparam [4:0] last_round_constant_23 = 5'b11001;
localparam [4:0] last_round_constant_22 = 5'b01100;
localparam [4:0] last_round_constant_21 = 5'b10110;
localparam [4:0] last_round_constant_20 = 5'b01011;
localparam [4:0] last_round_constant_18 = 5'b01010;
localparam [4:0] last_round_constant_16 = 5'b01110;
localparam [4:0] last_round_constant_12 = 5'b00001;
localparam [4:0] last_round_constant_0 = 5'b01111;

wire permutation_rc_enable;
wire permutation_rc_start;
(* keep *) reg [4:0] permutation_rc_c;
(* keep *) reg [4:0] permutation_rc_d;
reg is_last_rc;

wire accumulated_tag_difference_reset;
reg [7:0] accumulated_tag_difference;
wire tag_accumulated_tag_out;

wire [7:0] tag_difference;

wire permutation_state_din_direct_din;
wire receiving_data;
wire tag_generation_mode;
wire tag_verification_mode;

reg [7:0] reg_dout;
reg reg_dout_valid;
reg reg_dout_enable;

always @(*) begin
    if(ctr_data_size == 32'd0) begin
        is_ctr_data_size_zero =  1'b1;
    end else begin
        is_ctr_data_size_zero =  1'b0;
    end
end

always @(*) begin
    if(ctr_data_size == 32'd1) begin
        is_ctr_data_size_one =  1'b1;
    end else begin
        is_ctr_data_size_one =  1'b0;
    end
end

always @(*) begin
    if(din == 8'd0) begin
        is_din_zero =  1'b1;
    end else begin
        is_din_zero =  1'b0;
    end
end

assign is_ctr_data_size_start_zero = is_ctr_data_size_zero & is_din_zero;

assign new_ctr_data_size = ctr_data_size - 32'd01;

always @(posedge clk) begin
    if(ctr_data_size_enable == 1'b1) begin
        if(ctr_data_size_load == 1'b1) begin
            if((din_valid == 1'b1)) begin
                ctr_data_size <= {din, ctr_data_size[31:8]};
            end
        end else if((din_valid == 1'b1) || (tag_generation_mode == 1'b1 && dout_ready == 1'b1)) begin
            ctr_data_size <= new_ctr_data_size;
        end
    end
end

always @(*) begin
    if(ctr_data_duplex == 4'd1) begin
        is_ctr_data_duplex_one = 1'b1;
    end else begin
        is_ctr_data_duplex_one = 1'b0;
    end
end

always @(*) begin
    if(ctr_data_duplex == 4'd0) begin
        is_ctr_data_duplex_zero = 1'b1;
    end else begin
        is_ctr_data_duplex_zero = 1'b0;
    end
end

assign new_ctr_data_duplex = ctr_data_duplex - 4'b0001;
assign ctr_data_duplex_ctr_valid = din_valid | ctr_data_duplex_force_valid | (tag_generation_mode & dout_ready);

always @(posedge clk) begin
    if(ctr_data_duplex_enable == 1'b1) begin
        if((ctr_data_duplex_start == 1'b1)) begin
            if(ctr_data_duplex_start_value == 1'b1) begin
                ctr_data_duplex <= 4'd3;
            end else begin
                ctr_data_duplex <= 4'd15;
            end
        end else if((ctr_data_duplex_ctr_valid == 1'b1)) begin
            ctr_data_duplex <= new_ctr_data_duplex;
        end
    end
end

assign permutation_din_valid = din_valid | permutation_force_din_valid | (tag_generation_mode & dout_ready);

always @(*) begin
    case(permutation_din_type)
        2'b00 : begin
            permutation_din = 8'h00;
        end
        2'b01 : begin
            permutation_din = 8'h02;
        end
        2'b10 : begin
            permutation_din = 8'h03;
        end
        default : begin
            permutation_din = din;
        end
    endcase
end

assign permutation_din_xor_state = permutation_din ^ permutation_state[7:0];

assign friet_permutation_state_a[0] = permutation_state[127:0];
assign friet_permutation_state_b[0] = permutation_state[255:128];
assign friet_permutation_state_c[0] = permutation_state[383:256];
assign friet_permutation_state_d[0] = permutation_state_parity;
assign friet_permutation_rc_c[0] = permutation_rc_c;
assign friet_permutation_rc_d[0] = permutation_rc_d;

generate
    genvar gen_j;
    for (gen_j = 0; gen_j < COMBINATIONAL_ROUNDS; gen_j = gen_j + 1) begin: all_combinational_rounds
        (* keep_hierarchy *)
        friet_permutation_protected_round  permutation_gen_j(
            .a(friet_permutation_state_a[gen_j]),
            .b(friet_permutation_state_b[gen_j]),
            .c(friet_permutation_state_c[gen_j]),
            .d(friet_permutation_state_d[gen_j]),
            .rc_c(friet_permutation_rc_c[gen_j]),
            .rc_d(friet_permutation_rc_d[gen_j]),
            .new_a(friet_permutation_state_new_a[gen_j]),
            .new_b(friet_permutation_state_new_b[gen_j]),
            .new_c(friet_permutation_state_new_c[gen_j]),
            .new_d(friet_permutation_state_new_d[gen_j])
            );
            
        (* keep_hierarchy *)
        friet_permutation_rc rc_c_gen_j(
            .rc(friet_permutation_rc_c[gen_j]),
            .new_rc(frit_permutation_new_rc_c[gen_j])
        );
        (* keep_hierarchy *)
        friet_permutation_rc rc_d_gen_j(
            .rc(friet_permutation_rc_d[gen_j]),
            .new_rc(frit_permutation_new_rc_d[gen_j])
        );
        
        if(gen_j > 0) begin: all_combinational_rounds_next_iteration
            assign friet_permutation_state_a[gen_j]  = friet_permutation_state_new_a[gen_j-1];
            assign friet_permutation_state_b[gen_j]  = friet_permutation_state_new_b[gen_j-1];
            assign friet_permutation_state_c[gen_j]  = friet_permutation_state_new_c[gen_j-1];
            assign friet_permutation_state_d[gen_j]  = friet_permutation_state_new_d[gen_j-1];
            assign friet_permutation_rc_c[gen_j] = frit_permutation_new_rc_c[gen_j-1];
            assign friet_permutation_rc_d[gen_j] = frit_permutation_new_rc_d[gen_j-1];
        end
    end
endgenerate

always @(posedge clk) begin
    if(permutation_rc_enable == 1'b1) begin
        if(permutation_rc_start == 1'b1) begin
            permutation_rc_c <= master_round_constant;
        end else begin
            permutation_rc_c <= frit_permutation_new_rc_c[COMBINATIONAL_ROUNDS-1];
        end
    end
end

always @(posedge clk) begin
    if(permutation_rc_enable == 1'b1) begin
        if(permutation_rc_start == 1'b1) begin
            permutation_rc_d <= master_round_constant;
        end else begin
            permutation_rc_d <= frit_permutation_new_rc_d[COMBINATIONAL_ROUNDS-1];
        end
    end
end

generate
    if(COMBINATIONAL_ROUNDS == 1) begin: last_round_for_1_round
        always @(*) begin
            if(permutation_rc_c == last_round_constant_23) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 2) begin: last_round_for_2_rounds
        always @(*) begin
            if(permutation_rc_c == last_round_constant_22) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 3) begin: last_round_for_3_rounds
        always @(*) begin
            if(permutation_rc_c == last_round_constant_21) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 4) begin: last_round_for_4_rounds
        always @(*) begin
            if(permutation_rc_c == last_round_constant_20) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 6) begin: last_round_for_6_rounds
        always @(*) begin
            if(permutation_rc_c == last_round_constant_18) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 8) begin: last_round_for_8_rounds
        always @(*) begin
            if(permutation_rc_c == last_round_constant_16) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 12) begin: last_round_for_12_rounds
        always @(*) begin
            if(permutation_rc_c == last_round_constant_12) begin
                is_last_rc = 1'b1;
            end else begin
                is_last_rc = 1'b0;
            end
        end
    end else if(COMBINATIONAL_ROUNDS == 24) begin: last_round_for_24_rounds
        always @(*) begin
            if(permutation_rc_c == last_round_constant_0) begin
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

always @(posedge clk) begin
    if(permutation_state_reset == 1'b1) begin
        internal_fault_detected <= 1'b0;
    end else begin
        internal_fault_detected <= internal_fault_detected | internal_new_fault_detected;
    end
end

generate
    for (gen_j = 0; gen_j < 128; gen_j = gen_j + 1) begin: all_parity_bits
        (* keep_hierarchy *) xor PARITY_XOR(computed_parity[gen_j], permutation_state[gen_j], permutation_state[gen_j+128], permutation_state[gen_j+256], permutation_state_parity[gen_j]);
    end
endgenerate

assign permutation_state_one_round = {friet_permutation_state_new_c[COMBINATIONAL_ROUNDS-1], friet_permutation_state_new_b[COMBINATIONAL_ROUNDS-1], friet_permutation_state_new_a[COMBINATIONAL_ROUNDS-1]};

assign permutation_state_parity_direct_din = permutation_state[15:8] ^ din ^ permutation_state[263:256];
assign permutation_state_parity_din        = permutation_state[15:8] ^ permutation_din ^ permutation_state[7:0] ^ permutation_state[263:256];
assign permutation_state_parity_shift      = permutation_state_parity[127:8] ^ permutation_state[127:8] ^ permutation_state[135:16];

always @(posedge clk) begin
    if(permutation_state_reset == 1'b1) begin
        permutation_state <= 384'b0;
        permutation_state_parity <= 128'b0;
    end else begin
        if(permutation_state_mode_duplex == 1'b1) begin
            if(permutation_din_valid == 1'b1) begin
                if(permutation_state_din_direct_din == 1'b1) begin
                    permutation_state[135:0] <= {din, permutation_state[135:8]};
                    permutation_state_parity[7:0]   <= permutation_state_parity_direct_din;
                    permutation_state_parity[127:8] <= permutation_state_parity_shift;
                end else begin
                    permutation_state[135:0] <= {permutation_din_xor_state, permutation_state[135:8]};
                    permutation_state_parity[7:0]   <= permutation_state_parity_din;
                    permutation_state_parity[127:8] <= permutation_state_parity_shift;
                end
            end
        end else if(permutation_state_mode_new_round == 1'b1) begin
            permutation_state <= permutation_state_one_round;
            permutation_state_parity <= friet_permutation_state_new_d[COMBINATIONAL_ROUNDS-1];
        end
    end
end

always @(*) begin
    if((receiving_data == 1'b1 && din_valid == 1'b1) || (tag_generation_mode == 1'b1 && dout_ready == 1'b1)) begin
        reg_dout_enable = 1'b1;
    end else begin
        reg_dout_enable = 1'b0;
    end
end

assign tag_difference = din ^ permutation_state[7:0];

always @(posedge clk) begin
    if(accumulated_tag_difference_reset == 1'b1) begin
        accumulated_tag_difference <= 8'b00;
    end else if(receiving_data == 1'b1 && din_valid == 1'b1 && tag_verification_mode == 1'b1) begin
        accumulated_tag_difference <= accumulated_tag_difference | tag_difference;
    end
end

always @(posedge clk or negedge arstn) begin
    if(arstn == 1'b0) begin
        reg_dout <= 8'b00;
    end else if(reg_dout_enable == 1'b1) begin
        if(tag_verification_mode == 1'b1) begin
            if(tag_accumulated_tag_out == 1'b1) begin
                reg_dout <= accumulated_tag_difference;
            end else begin
                reg_dout <= tag_difference;
            end
        end else begin
            reg_dout <= permutation_din_xor_state;
        end
    end
end

always @(posedge clk or negedge arstn) begin
    if(arstn == 1'b0) begin
        reg_dout_valid <= 1'b0;
    end else if(reg_dout_enable == 1'b1) begin
        reg_dout_valid <= 1'b1;
    end else begin
        reg_dout_valid <= 1'b0;
    end
end

assign dout = reg_dout;
assign dout_valid = reg_dout_valid;

assign fault_detected = internal_fault_detected;

friet_ae_protected_8_bits_state_machine state_machine(
    .clk(clk),
    .arstn(arstn),
    .din(din),
    .din_valid(din_valid),
    .dout_ready(dout_ready),
    .din_ready(din_ready),
    .is_ctr_data_size_one(is_ctr_data_size_one),
    .is_ctr_data_size_zero(is_ctr_data_size_zero),
    .is_ctr_data_size_start_zero(is_ctr_data_size_start_zero),
    .ctr_data_size_enable(ctr_data_size_enable),
    .ctr_data_size_load(ctr_data_size_load),
    .is_ctr_data_duplex_zero(is_ctr_data_duplex_zero),
    .is_ctr_data_duplex_one(is_ctr_data_duplex_one),
    .ctr_data_duplex_start(ctr_data_duplex_start),
    .ctr_data_duplex_enable(ctr_data_duplex_enable),
    .ctr_data_duplex_force_valid(ctr_data_duplex_force_valid),
    .ctr_data_duplex_start_value(ctr_data_duplex_start_value),
    .permutation_force_din_valid(permutation_force_din_valid),
    .permutation_din_type(permutation_din_type),
    .permutation_state_reset(permutation_state_reset),
    .permutation_state_mode_duplex(permutation_state_mode_duplex),
    .permutation_state_mode_new_round(permutation_state_mode_new_round),
    .permutation_state_din_direct_din(permutation_state_din_direct_din),
    .is_last_rc(is_last_rc),
    .permutation_rc_enable(permutation_rc_enable),
    .permutation_rc_start(permutation_rc_start),
    .accumulated_tag_difference_reset(accumulated_tag_difference_reset),
    .tag_accumulated_tag_out(tag_accumulated_tag_out),
    .receiving_data(receiving_data),
    .tag_generation_mode(tag_generation_mode),
    .tag_verification_mode(tag_verification_mode)
);

endmodule