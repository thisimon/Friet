/**
 Implementation by Pedro Maat C. Massolino,
 hereby denoted as "the implementer".

 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
*/
module friet_permutation_n_rounds_with_communication(clk, arstn, start, data_in_valid, data_out_ready, data_in, data_out, data_out_valid, data_in_ready, finish, core_free);

parameter BUFFER_LENGTH = 8;
parameter COMBINATIONAL_ROUNDS = 1;

input clk;
input arstn;
input start;
input data_in_valid;
input data_out_ready;
input [(BUFFER_LENGTH-1):0] data_in;
output [(BUFFER_LENGTH-1):0] data_out;
output data_out_valid;
output data_in_ready;
output finish;
output core_free;

wire permutation_start_enable;
wire permutation_state_buffer_in_enabled;
wire [(BUFFER_LENGTH-1):0] permutation_state_buffer_in;
wire permutation_state_buffer_out_enabled;
wire [383:0] permutation_state_buffer;
wire permutation_core_free;
wire permutation_core_finish;

reg internal_data_in_ready;
reg internal_data_out_valid;

assign permutation_start_enable = start;
assign permutation_state_buffer_in_enabled = data_in_valid;
assign permutation_state_buffer_in = data_in;
assign permutation_state_buffer_out_enabled = data_out_ready & internal_data_out_valid;

friet_permutation_n_rounds_no_communication
#(.BUFFER_LENGTH(BUFFER_LENGTH),
.COMBINATIONAL_ROUNDS(COMBINATIONAL_ROUNDS))
permutation(
    .clk(clk),
    .aresetn(arstn),
    .start_enable(permutation_start_enable),
    .state_buffer_in_enabled(permutation_state_buffer_in_enabled),
    .state_buffer_in(permutation_state_buffer_in),
    .state_buffer_out_enabled(permutation_state_buffer_out_enabled),
    .state_buffer(permutation_state_buffer),
    .core_free(permutation_core_free),
    .core_finish(permutation_core_finish)
);

always @(posedge clk or negedge arstn) begin
    if (!arstn) begin
        internal_data_out_valid <= 1'b0;
    end else begin
        if(permutation_core_free == 1'b0) begin
            internal_data_out_valid <= 1'b0;
        end else begin
            if(data_out_ready == 1'b1) begin
                internal_data_out_valid <= 1'b1;
            end else begin
                internal_data_out_valid <= 1'b0;
            end
        end
    end
end

always @(posedge clk or negedge arstn) begin
    if (!arstn) begin
        internal_data_in_ready <= 1'b1;
    end else begin
        if(permutation_core_free == 1'b0) begin
            internal_data_in_ready <= 1'b0;
        end else begin
            if(permutation_core_finish == 1'b1) begin
                internal_data_in_ready <= 1'b1;
            end
        end
    end
end

assign data_out = permutation_state_buffer[(BUFFER_LENGTH-1):0];
assign data_out_valid = internal_data_out_valid;
assign data_in_ready = internal_data_in_ready;
assign finish = permutation_core_finish;
assign core_free = permutation_core_free;

endmodule