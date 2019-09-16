/**
 Implementation by Pedro Maat C. Massolino,
 hereby denoted as "the implementer".

 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
*/
`timescale 1ns / 1ps
module tb_friet_permutation_protected_n_rounds_with_communication();

parameter PERIOD = 1000;
parameter maximum_number_of_tests = 100;
parameter test_memory_file_friet_permutation = "../data_tests/friet_permutation.dat";
parameter test_buffer_length = 8;
parameter test_combinational_rounds = 3;

parameter state_size = 384;

reg [state_size-1:0] test_state;
reg [state_size-1:0] test_new_state;
reg [state_size-1:0] true_new_state;

reg test_arstn;
reg test_start;
reg test_data_in_valid;
reg test_data_out_ready;
reg [test_buffer_length-1:0] test_data_in;
wire [test_buffer_length-1:0] test_data_out;
wire test_data_out_valid;
wire test_data_in_ready;
wire test_finish;
wire test_core_free;
wire test_fault_detected;

reg clk;
reg test_error = 1'b0;
reg test_verification = 1'b0;

localparam tb_delay = PERIOD/2;
localparam tb_delay_read = 3*PERIOD/4;

friet_permutation_protected_n_rounds_with_communication
#(
.BUFFER_LENGTH(test_buffer_length),
.COMBINATIONAL_ROUNDS(test_combinational_rounds)
)
test (
    .clk(clk),
    .arstn(test_arstn),
    .start(test_start),
    .data_in_valid(test_data_in_valid),
    .data_out_ready(test_data_out_ready),
    .data_in(test_data_in),
    .data_out(test_data_out),
    .data_out_valid(test_data_out_valid),
    .data_in_ready(test_data_in_ready),
    .finish(test_finish),
    .core_free(test_core_free),
    .fault_detected(test_fault_detected)
);
    
initial begin : clock_generator
    clk <= 1'b1;
    forever begin
        #(PERIOD/2);
        clk <= ~clk;
    end
end

task load_value;
    input [state_size-1:0] state_in;
    integer i;
    begin
        test_data_in <= {test_buffer_length{1'b0}};
        test_data_in_valid <= 1'b0;
        i = 0;
        #PERIOD;
        while (i < (state_size)) begin
            test_data_in <= state_in[i +:test_buffer_length];
            test_data_in_valid <= 1'b1;
            #PERIOD;
            i = i + test_buffer_length;
        end
        test_data_in_valid <= 1'b0;
        #PERIOD;
    end
endtask

task retrieve_value;
    output [state_size-1:0] state_out;
    integer i;
    begin
        test_data_out_ready <= 1'b1;
        i = 0;
        #PERIOD;
        while (i < (state_size)) begin
            if(test_data_out_valid == 1'b1) begin
                state_out <= {test_data_out, state_out[state_size-1:test_buffer_length]};
                i = i + test_buffer_length;
            end
            #PERIOD;
        end
        test_data_out_ready <= 1'b0;
        #PERIOD;
    end
endtask

integer ram_file;
integer number_of_tests;
integer test_iterator;
integer cycle_counter;
integer status_ram_file;
initial begin
    test_arstn <= 1'b0;
    test_start <= 1'b0;
    test_data_in_valid <= 1'b0;
    test_data_out_ready <= 1'b0;
    test_data_in <= 1'b0;
    #(PERIOD*2);
    test_arstn <= 1'b1;
    #(PERIOD);
    #(tb_delay);
    ram_file = $fopen(test_memory_file_friet_permutation, "r");
    status_ram_file = $fscanf(ram_file, "%d", number_of_tests);
    #(PERIOD);
    if((number_of_tests > maximum_number_of_tests) && (maximum_number_of_tests != 0)) begin
        number_of_tests = maximum_number_of_tests;
    end
    for (test_iterator = 1; test_iterator < number_of_tests; test_iterator = test_iterator + 1) begin
        test_error <= 1'b0;
        status_ram_file = $fscanf(ram_file, "%b", test_state);
        status_ram_file = $fscanf(ram_file, "%b", true_new_state);
        while(test_data_in_ready == 1'b0) begin
            #PERIOD;
        end
        load_value(test_state);
        #PERIOD;
        test_start <= 1'b1;
        #PERIOD;
        test_start <= 1'b0;
        cycle_counter = 1;
        #PERIOD;
        while(test_finish != 1'b1) begin
            cycle_counter = cycle_counter + 1;
            #PERIOD;
        end
        if(test_iterator == 1) begin
            $display("Operation time = %d cycles", cycle_counter);
        end
        #PERIOD;
        retrieve_value(test_new_state);
        #PERIOD;
        test_verification <= 1'b1;
        if (true_new_state == test_new_state) begin
            test_error <= 1'b0;
        end else begin
            test_error <= 1'b1;
            $display("Computed values do not match expected ones");
        end
        #PERIOD;
        test_verification <= 1'b0;
        test_error <= 1'b0;
        #PERIOD;
    end
    $fclose(ram_file);
    $display("End of the test.");
    disable clock_generator;
    #(PERIOD);
end

initial
begin
    $dumpfile("dump.vcd");
    $dumpvars(1, tb_friet_permutation_protected_n_rounds_with_communication);
end

endmodule