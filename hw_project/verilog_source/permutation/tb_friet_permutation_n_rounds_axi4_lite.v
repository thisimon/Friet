/**
 Implementation by Pedro Maat C. Massolino,
 hereby denoted as "the implementer".

 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
*/
`timescale 1ns / 1ps
module tb_friet_permutation_n_rounds_axi4_lite();

parameter PERIOD = 1000;
parameter maximum_number_of_tests = 100;
parameter maximum_line_length = 10000;
parameter test_memory_file_friet_permutation = "../data_tests/friet_permutation.dat";
parameter test_combinational_rounds = 2;

parameter state_size = 384;

reg [state_size-1:0] test_state;
reg [state_size-1:0] test_new_state;
reg [state_size-1:0] true_new_state;

reg test_aresetn;
reg [3:0] test_s_axi_awaddr;
reg [2:0] test_s_axi_awprot;
reg test_s_axi_awvalid;
wire test_s_axi_awready;
reg [31:0] test_s_axi_wdata;
reg [3:0]  test_s_axi_wstrb;
reg test_s_axi_wvalid;
wire test_s_axi_wready;
wire [1:0] test_s_axi_bresp;
wire test_s_axi_bvalid;
reg test_s_axi_bready;
reg [3:0] test_s_axi_araddr;
reg [2:0] test_s_axi_arprot;
reg test_s_axi_arvalid;
wire test_s_axi_arready;
wire [31:0] test_s_axi_rdata;
wire [1:0]  test_s_axi_rresp;
wire test_s_axi_rvalid;
reg test_s_axi_rready;

reg [31:0] test_temp_buffer_out;

reg clk;
reg test_error = 1'b0;
reg test_verification = 1'b0;

localparam tb_delay = PERIOD/2;
localparam tb_delay_read = 3*PERIOD/4;

initial begin : clock_generator
    clk <= 1'b1;
    forever begin
        #(PERIOD/2);
        clk <= ~clk;
    end
end

friet_permutation_n_rounds_axi4_lite
#(
.COMBINATIONAL_ROUNDS(test_combinational_rounds))
test (
    .aclk(clk),
    .aresetn(test_aresetn),
    .s_axi_awaddr(test_s_axi_awaddr),
    .s_axi_awprot(test_s_axi_awprot),
    .s_axi_awvalid(test_s_axi_awvalid),
    .s_axi_awready(test_s_axi_awready),
    .s_axi_wdata(test_s_axi_wdata),
    .s_axi_wstrb(test_s_axi_wstrb),
    .s_axi_wvalid(test_s_axi_wvalid),
    .s_axi_wready(test_s_axi_wready),
    .s_axi_bresp(test_s_axi_bresp),
    .s_axi_bvalid(test_s_axi_bvalid),
    .s_axi_bready(test_s_axi_bready),
    .s_axi_araddr(test_s_axi_araddr),
    .s_axi_arprot(test_s_axi_arprot),
    .s_axi_arvalid(test_s_axi_arvalid),
    .s_axi_arready(test_s_axi_arready),
    .s_axi_rdata(test_s_axi_rdata),
    .s_axi_rresp(test_s_axi_rresp),
    .s_axi_rvalid(test_s_axi_rvalid),
    .s_axi_rready(test_s_axi_rready)
);

task axi_4_lite_write_value;
    input [3:0] address;
    input [31:0] value;
    begin
        test_s_axi_awaddr <= 4'h0;
        test_s_axi_awprot <= 3'b000;
        test_s_axi_awvalid <= 1'b0;
        test_s_axi_wdata <= 32'b0;
        test_s_axi_wstrb <= 4'b0000;
        test_s_axi_wvalid <= 1'b0;
        test_s_axi_bready <= 1'b0;
        test_s_axi_araddr <= 4'h0;
        test_s_axi_arprot <= 3'b000;
        test_s_axi_arvalid <= 1'b0;
        test_s_axi_rready <= 1'b0;
        #(PERIOD);
        test_s_axi_awaddr <= address;
        test_s_axi_awprot <= 3'b000;
        test_s_axi_awvalid <= 1'b1;
        test_s_axi_wdata <= value;
        test_s_axi_wstrb <= 4'b1111;
        test_s_axi_wvalid <= 1'b1;
        if((test_s_axi_awvalid != 1'b1) || (test_s_axi_awready != 1'b1)) begin
            #(PERIOD);
        end
        if((test_s_axi_wvalid != 1'b1) || (test_s_axi_wready != 1'b1)) begin
            #(PERIOD);
        end
        test_s_axi_awaddr <= 4'h0;
        test_s_axi_awprot <= 3'b000;
        test_s_axi_awvalid <= 1'b0;
        test_s_axi_wdata <= 32'b0;
        test_s_axi_wstrb <= 4'b0000;
        test_s_axi_wvalid <= 1'b0;
        test_s_axi_bready <= 1'b1;
        if((test_s_axi_bvalid != 1'b1) || (test_s_axi_bready != 1'b1)) begin
            #(PERIOD);
        end
        #(PERIOD);
        test_s_axi_bready <= 1'b0;
        #(PERIOD);
    end
endtask

task axi_4_lite_read_value;
    input [3:0] address;
    output [31:0] value;
    begin
        test_s_axi_awaddr <= 4'h0;
        test_s_axi_awprot <= 3'b000;
        test_s_axi_awvalid <= 1'b0;
        test_s_axi_wdata <= 32'b0;
        test_s_axi_wstrb <= 4'b0000;
        test_s_axi_wvalid <= 1'b0;
        test_s_axi_bready <= 1'b0;
        test_s_axi_araddr <= 4'h0;
        test_s_axi_arprot <= 3'b000;
        test_s_axi_arvalid <= 1'b0;
        test_s_axi_rready <= 1'b0;
        #(PERIOD);
        test_s_axi_araddr <= address;
        test_s_axi_arprot <= 3'b000;
        test_s_axi_arvalid <= 1'b1;
        if((test_s_axi_arvalid != 1'b1) || (test_s_axi_arready != 1'b1)) begin
            #(PERIOD);
        end
        test_s_axi_araddr <= 8'h00;
        test_s_axi_arprot <= 3'b000;
        test_s_axi_arvalid <= 1'b0;
        test_s_axi_rready <= 1'b1;
        if((test_s_axi_rvalid != 1'b1) || (test_s_axi_rready != 1'b1)) begin
            #(PERIOD);
        end
        #(PERIOD);
        test_s_axi_rready <= 1'b0;
        value <= test_s_axi_rdata;
        #(PERIOD);
    end
endtask

task load_value;
    input [state_size-1:0] state_in;
    integer i;
    begin
        i = 0;
        #PERIOD;
        while (i < (state_size)) begin
            test_temp_buffer_out = state_in[i +:32];
            axi_4_lite_write_value(4'h4, test_temp_buffer_out);
            i = i + 32;
            #PERIOD;
        end
        #PERIOD;
    end
endtask

task retrieve_value;
    output [state_size-1:0] state_out;
    integer i;
    begin
        i = 0;
        #(PERIOD);
        while (i < (state_size)) begin
            axi_4_lite_read_value(4'h0, test_temp_buffer_out);
            state_out = {test_temp_buffer_out, state_out[state_size-1:32]};
            i = i + 32;
            #(PERIOD);
        end
        #(PERIOD);
    end
endtask

integer ram_file;
integer number_of_tests;
integer test_iterator;
integer cycle_counter;
integer status_ram_file;
initial begin
    test_aresetn <= 1'b0;
    test_s_axi_awaddr <= 8'h00;
    test_s_axi_awprot <= 3'b000;
    test_s_axi_awvalid <= 1'b0;
    test_s_axi_wdata <= 32'b0;
    test_s_axi_wstrb <= 4'b0000;
    test_s_axi_wvalid <= 1'b0;
    test_s_axi_bready <= 1'b0;
    test_s_axi_araddr <= 8'h00;
    test_s_axi_arprot <= 3'b000;
    test_s_axi_arvalid <= 1'b0;
    test_s_axi_rready <= 1'b0;
    
    test_error <= 1'b0;
    test_verification <= 1'b0;
    #(PERIOD*2);
    test_aresetn <= 1'b1;
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
        load_value(test_state);
        #PERIOD;
        test_temp_buffer_out = 32'b01;
        axi_4_lite_write_value(4'h8, test_temp_buffer_out);
        cycle_counter = 1;
        while(test_s_axi_arready != 1'b1) begin
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
    $dumpvars(0, tb_friet_permutation_n_rounds_axi4_lite);
end

endmodule