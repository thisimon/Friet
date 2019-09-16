/**
 Implementation by Pedro Maat C. Massolino,
 hereby denoted as "the implementer".

 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
*/
`timescale 1ns / 1ps
module tb_friet_ae_protected_32_bits();

parameter PERIOD = 1000;
parameter maximum_number_of_tests = 100;
parameter maximum_line_length = 10000;
parameter test_memory_file_friet_ae_initialization = "../data_tests/friet_ae.dat";
parameter test_combinational_rounds = 1;
parameter array_max_size = 1024;

reg test_arstn;
reg [31:0] test_din;
reg test_din_valid;
wire test_din_ready;
wire [31:0] test_dout;
wire test_dout_valid;
reg test_dout_ready;

reg [array_max_size-1:0] test_key;
reg [31:0] test_key_size;
reg [array_max_size-1:0] test_nonce;
reg [31:0] test_nonce_size;
reg [array_max_size-1:0] test_key_tag;
reg [31:0] test_key_tag_size;
reg [array_max_size-1:0] true_key_tag;
reg [31:0] true_key_tag_size;
reg [array_max_size-1:0] test_ad;
reg [31:0] test_ad_size;
reg [array_max_size-1:0] test_pt;
reg [31:0] test_pt_size;
reg [array_max_size-1:0] test_ct;
reg [31:0] test_ct_size;
reg [array_max_size-1:0] test_tag;
reg [31:0] test_tag_size;
reg [array_max_size-1:0] true_pt;
reg [31:0] true_pt_size;
reg [array_max_size-1:0] true_ct;
reg [31:0] true_ct_size;
reg [array_max_size-1:0] true_tag;
reg [31:0] true_tag_size;
reg [31:0] verification_tag;

reg [383:0] true_debug_state;


reg clk;
reg test_error = 1'b0;
reg test_verification = 1'b0;

localparam tb_delay = PERIOD/2;
localparam tb_delay_read = 3*PERIOD/4;
localparam number_of_wait_cycles = 0;

initial begin : clock_generator
    clk <= 1'b1;
    forever begin
        #(PERIOD/2);
        clk <= ~clk;
    end
end

friet_ae_protected_32_bits
#(
    .COMBINATIONAL_ROUNDS(test_combinational_rounds)
)
test (
    .clk(clk),
    .arstn(test_arstn),
    .din(test_din),
    .din_valid(test_din_valid),
    .din_ready(test_din_ready),
    .dout(test_dout),
    .dout_valid(test_dout_valid),
    .dout_ready(test_dout_ready),
    .fault_detected(test_fault_detected)
);

task send_key_or_nonce;
    input [array_max_size-1:0] send_array;
    input [31:0] send_array_size;
    integer i;
    begin
        i = 0;
        if(test_din_ready == 1'b1) begin
            test_din = send_array_size;
            test_din_valid = 1'b1;
            #(PERIOD);
            test_din_valid = 1'b0;
            test_din = 32'b0;
            #(number_of_wait_cycles*PERIOD);
        end else begin
            test_din = send_array_size;
            test_din_valid = 1'b1;
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
            test_din_valid = 1'b0;
            test_din = 32'b0;
            #(number_of_wait_cycles*PERIOD);
        end
        i = 0;
        while(i < send_array_size*8) begin
            if(test_din_ready == 1'b1) begin
                test_din = send_array[i +:32];
                test_din_valid = 1'b1;
                #(PERIOD);
                i = i + 32;
                test_din_valid = 1'b0;
                test_din = 32'b0;
                #(number_of_wait_cycles*PERIOD);
            end else begin
                test_din = send_array[i +:32];
                test_din_valid = 1'b1;
                #(PERIOD);
                while(test_din_ready != 1'b1) begin
                    #(PERIOD);
                end
                #(PERIOD);
                i = i + 32;
                test_din_valid = 1'b0;
                test_din = 32'b0;
                #(number_of_wait_cycles*PERIOD);
            end
        end
    end
endtask

task send_ad;
    input [array_max_size-1:0] send_array;
    input [31:0] send_array_size;
    integer i;
    begin
        i = 0;
        if(test_din_ready == 1'b1) begin
            test_din = send_array_size;
            test_din_valid = 1'b1;
            #(PERIOD);
            test_din_valid = 1'b0;
            test_din = 32'b0;
            #(number_of_wait_cycles*PERIOD);
        end else begin
            test_din = send_array_size;
            test_din_valid = 1'b1;
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
            test_din_valid = 1'b0;
            test_din = 32'b0;
            #(number_of_wait_cycles*PERIOD);
        end
        i = 0;
        while(i < send_array_size*8) begin
            if(test_din_ready == 1'b1) begin
                test_din = send_array[i +:32];
                test_din_valid = 1'b1;
                #(PERIOD);
                i = i + 32;
                test_din_valid = 1'b0;
                test_din = 32'b0;
                #(number_of_wait_cycles*PERIOD);
            end else begin
                test_din = send_array[i +:32];
                test_din_valid = 1'b1;
                #(PERIOD);
                while(test_din_ready != 1'b1) begin
                    #(PERIOD);
                end
                #(PERIOD);
                i = i + 32;
                test_din_valid = 1'b0;
                test_din = 32'b0;
                #(number_of_wait_cycles*PERIOD);
            end
        end
    end
endtask

task send_pt_receive_ct;
    input [array_max_size-1:0] send_array;
    input [31:0] send_array_size;
    output [array_max_size-1:0] receive_array;
    integer i;
    begin
        i = 0;
        receive_array = {array_max_size{1'b0}};
        if(test_din_ready == 1'b1) begin
            test_din = send_array_size[i +:32];
            test_din_valid = 1'b1;
            #(PERIOD);
            i = i + 32;
            test_din_valid = 1'b0;
            test_din = 32'b0;
            #(number_of_wait_cycles*PERIOD);
        end else begin
            test_din = send_array_size[i +:32];
            test_din_valid = 1'b1;
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
            i = i + 32;
            test_din_valid = 1'b0;
            test_din = 32'b0;
            #(number_of_wait_cycles*PERIOD);
        end
        i = 0;
        while(i < send_array_size*8) begin
            if(test_din_ready == 1'b1) begin
                test_din = send_array[i +:32];
                test_din_valid = 1'b1;
                #(PERIOD);
                receive_array[i +:32] = test_dout;
                i = i + 32;
                test_din_valid = 1'b0;
                test_din = 32'b0;
                #((number_of_wait_cycles+1)*PERIOD);
            end else begin
                test_din = send_array[i +:32];
                test_din_valid = 1'b1;
                #(PERIOD);
                while(test_din_ready != 1'b1) begin
                    #(PERIOD);
                end
                #(PERIOD);
                receive_array[i +:32] = test_dout;
                i = i + 32;
                test_din_valid = 1'b0;
                test_din = 32'b0;
                #((number_of_wait_cycles+1)*PERIOD);
            end
        end
    end
endtask

task receive_tag;
    input [31:0] receive_array_size;
    output [array_max_size-1:0] receive_array;
    integer i;
    begin
        i = 0;
        receive_array = {array_max_size{1'b0}};
        while(i < 32) begin
            if(test_din_ready == 1'b1) begin
                test_din = receive_array_size[i +:32];
                test_din_valid = 1'b1;
                #(PERIOD);
                i = i + 32;
                test_din_valid = 1'b0;
                test_din = 32'b0;
                #(number_of_wait_cycles*PERIOD);
            end else begin
                test_din = receive_array_size[i +:32];
                test_din_valid = 1'b1;
                #(PERIOD);
                while(test_din_ready != 1'b1) begin
                    #(PERIOD);
                end
                #(PERIOD);
                i = i + 32;
                test_din_valid = 1'b0;
                test_din = 32'b0;
                #(number_of_wait_cycles*PERIOD);
            end
        end
        i = 0;
        while(i < receive_array_size*8) begin
            test_dout_ready = 1'b1;
            #(PERIOD);
            if(test_dout_valid == 1'b1) begin
                receive_array[i +:32] = test_dout;
                i = i + 32;
                test_dout_ready = 1'b0;
                #((number_of_wait_cycles+1)*PERIOD);
            end
        end
        test_dout_ready = 1'b0;
    end
endtask

task send_verify_tag;
    input [array_max_size-1:0] send_array;
    input [31:0] send_array_size;
    output [31:0] receive_array;
    integer i;
    begin
        i = 0;
        receive_array = {array_max_size{1'b0}};
        test_dout_ready = 1'b1;
        if(test_din_ready == 1'b1) begin
            test_din = send_array_size[i +:32];
            test_din_valid = 1'b1;
            #(PERIOD);
            i = i + 32;
            test_din_valid = 1'b0;
            test_din = 32'b0;
            #(number_of_wait_cycles*PERIOD);
        end else begin
            test_din = send_array_size[i +:32];
            test_din_valid = 1'b1;
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
            i = i + 32;
            test_din_valid = 1'b0;
            test_din = 32'b0;
            #(number_of_wait_cycles*PERIOD);
        end
        i = 0;
        if(send_array_size > 0) begin
            if(send_array_size > 4) begin
                while(i < ((send_array_size-4)*8)) begin
                    if(test_din_ready == 1'b1) begin
                        test_din = send_array[i +:32];
                        test_din_valid = 1'b1;
                        #(PERIOD);
                        receive_array = test_dout;
                        i = i + 32;
                        test_din_valid = 1'b0;
                        test_din = 32'b0;
                        #((number_of_wait_cycles+1)*PERIOD);
                    end else begin
                        test_din = send_array[i +:32];
                        test_din_valid = 1'b1;
                        #(PERIOD);
                        while(test_din_ready != 1'b1) begin
                            #(PERIOD);
                        end
                        #(PERIOD);
                        receive_array = test_dout;
                        i = i + 32;
                        test_din_valid = 1'b0;
                        test_din = 32'b0;
                        #((number_of_wait_cycles+1)*PERIOD);
                    end
                end
            end
            if(test_din_ready == 1'b1) begin
                test_din = send_array[i +:32];
                test_din_valid = 1'b1;
                #(PERIOD);
                receive_array = test_dout;
                test_din_valid = 1'b0;
                test_din = 32'b0;
                #(PERIOD);
                receive_array = test_dout;
                #((number_of_wait_cycles+1)*PERIOD);
            end else begin
                test_din = send_array[i +:32];
                test_din_valid = 1'b1;
                #(PERIOD);
                while(test_din_ready != 1'b1) begin
                    #(PERIOD);
                end
                #(PERIOD);
                receive_array = test_dout;
                test_din_valid = 1'b0;
                test_din = 32'b0;
                #(PERIOD);
                receive_array = test_dout;
                #((number_of_wait_cycles+1)*PERIOD);
            end
        end
        test_dout_ready = 1'b0;
    end
endtask

integer ram_file;
integer number_of_tests;
integer test_iterator;
integer status_ram_file;
integer load_iterator;
reg [7:0] test_read_buffer;
initial begin
    test_arstn <= 1'b0;
    test_din <= 32'b0;
    test_din_valid <= 1'b0;
    test_dout_ready <= 1'b0;
    test_key <= {array_max_size{1'b0}};
    test_key_size <= 32'b0;
    test_nonce <= {array_max_size{1'b0}};
    test_nonce_size <= 32'b0;
    test_key_tag <= {array_max_size{1'b0}};
    test_key_tag_size <= 32'b0;
    test_ad <= {array_max_size{1'b0}};
    test_ad_size <= 32'b0;
    test_pt <= {array_max_size{1'b0}};
    test_pt_size <= 32'b0;
    test_ct <= {array_max_size{1'b0}};
    test_ct_size <= 32'b0;
    test_tag <= {array_max_size{1'b0}};
    test_tag_size <= 32'b0;
    true_key_tag <= {array_max_size{1'b0}};
    true_key_tag_size <= 32'b0;
    true_pt <= {array_max_size{1'b0}};
    true_pt_size <= 32'b0;
    true_ct <= {array_max_size{1'b0}};
    true_ct_size <= 32'b0;
    true_tag <= {array_max_size{1'b0}};
    true_tag_size <= 32'b0;
    verification_tag <= 32'b0;
    test_error <= 1'b0;
    test_verification <= 1'b0;
    #(PERIOD*2);
    test_arstn <= 1'b1;
    #(PERIOD);
    #(tb_delay);
    ram_file = $fopen(test_memory_file_friet_ae_initialization, "r");
    status_ram_file = $fscanf(ram_file, "%d", number_of_tests);
    #(PERIOD);
    if((number_of_tests > maximum_number_of_tests) && (maximum_number_of_tests != 0)) begin
        number_of_tests = maximum_number_of_tests;
    end
    for (test_iterator = 1; test_iterator < number_of_tests; test_iterator = test_iterator + 1) begin
        test_error <= 1'b0;
        test_key <= {array_max_size{1'b0}};
        test_key_size <= 32'b0;
        test_nonce <= {array_max_size{1'b0}};
        test_nonce_size <= 32'b0;
        test_key_tag <= {array_max_size{1'b0}};
        test_key_tag_size <= 32'b0;
        test_ad <= {array_max_size{1'b0}};
        test_ad_size <= 32'b0;
        test_pt <= {array_max_size{1'b0}};
        test_pt_size <= 32'b0;
        test_ct <= {array_max_size{1'b0}};
        test_ct_size <= 32'b0;
        test_tag <= {array_max_size{1'b0}};
        test_tag_size <= 32'b0;
        true_key_tag <= {array_max_size{1'b0}};
        true_key_tag_size <= 32'b0;
        true_pt <= {array_max_size{1'b0}};
        true_pt_size <= 32'b0;
        true_ct <= {array_max_size{1'b0}};
        true_ct_size <= 32'b0;
        true_tag <= {array_max_size{1'b0}};
        true_tag_size <= 32'b0;
        verification_tag <= 32'b0;
        #(PERIOD);
        status_ram_file = $fscanf(ram_file, "%d", test_key_size);
        load_iterator = 0;
        while (load_iterator < test_key_size*8) begin
            status_ram_file = $fscanf(ram_file, "%b", test_read_buffer);
            test_key[load_iterator +:8] = test_read_buffer;
            load_iterator = load_iterator + 8;
        end
        status_ram_file = $fscanf(ram_file, "%d", test_nonce_size);
        load_iterator = 0;
        while (load_iterator < test_nonce_size*8) begin
            status_ram_file = $fscanf(ram_file, "%b", test_read_buffer);
            test_nonce[load_iterator +:8] = test_read_buffer;
            load_iterator = load_iterator + 8;
        end
        status_ram_file = $fscanf(ram_file, "%d", test_ad_size);
        load_iterator = 0;
        while (load_iterator < test_ad_size*8) begin
            status_ram_file = $fscanf(ram_file, "%b", test_read_buffer);
            test_ad[load_iterator +:8] = test_read_buffer;
            load_iterator = load_iterator + 8;
        end
        status_ram_file = $fscanf(ram_file, "%d", true_pt_size);
        test_pt_size = true_pt_size;
        load_iterator = 0;
        while (load_iterator < true_pt_size*8) begin
            status_ram_file = $fscanf(ram_file, "%b", test_read_buffer);
            true_pt[load_iterator +:8] = test_read_buffer;
            load_iterator = load_iterator + 8;
        end
        status_ram_file = $fscanf(ram_file, "%d", true_key_tag_size);
        test_key_tag_size = true_key_tag_size;
        load_iterator = 0;
        while (load_iterator < true_key_tag_size*8) begin
            status_ram_file = $fscanf(ram_file, "%b", test_read_buffer);
            true_key_tag[load_iterator +:8] = test_read_buffer;
            load_iterator = load_iterator + 8;
        end
        status_ram_file = $fscanf(ram_file, "%d", true_ct_size);
        test_ct_size = true_ct_size;
        load_iterator = 0;
        while (load_iterator < true_ct_size*8) begin
            status_ram_file = $fscanf(ram_file, "%b", test_read_buffer);
            true_ct[load_iterator +:8] = test_read_buffer;
            load_iterator = load_iterator + 8;
        end
        status_ram_file = $fscanf(ram_file, "%d", true_tag_size);
        test_tag_size = true_tag_size;
        load_iterator = 0;
        while (load_iterator < true_tag_size*8) begin
            status_ram_file = $fscanf(ram_file, "%b", test_read_buffer);
            true_tag[load_iterator +:8] = test_read_buffer;
            load_iterator = load_iterator + 8;
        end
        status_ram_file = $fscanf(ram_file, "%b", true_debug_state);
        #(PERIOD);
        /// Wrapping test
        test_din = 32'h00;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        #(PERIOD);
        
        test_din = 32'h01;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_key_or_nonce(test_key, test_key_size);
        #(PERIOD);
        
        test_din = 32'h02;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_key_or_nonce(test_nonce, test_nonce_size);
        #(PERIOD);
        
        test_din = 32'h04;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        receive_tag(test_key_tag_size, test_key_tag);
        #(PERIOD);
        
        test_din = 32'h01;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_ad(test_ad, test_ad_size);
        #(PERIOD);
        
        test_din = 32'h02;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_pt_receive_ct(true_pt, true_pt_size, test_ct);
        #(PERIOD);
        
        test_din = 32'h04;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        receive_tag(test_tag_size, test_tag);
        #(PERIOD);
        
        while(test_din_ready != 1'b1) begin
            #(PERIOD);
        end
        #(PERIOD);
        test_verification <= 1'b1;
        if (true_key_tag == test_key_tag) begin
            test_error <= 1'b0;
        end else begin
            test_error <= 1'b1;
            $display("Computed key tags do not match expected ones");
        end
        #(PERIOD);
        test_error <= 1'b0;
        #(PERIOD);
        if (true_ct == test_ct) begin
            test_error <= 1'b0;
        end else begin
            test_error <= 1'b1;
            $display("Computed ciphertext do not match expected ones");
        end
        #(PERIOD);
        test_error <= 1'b0;
        #(PERIOD);
        if (true_tag != test_tag) begin
            test_error <= 1'b1;
            $display("Computed tag do not match expected ones");
        end else begin
            test_error <= 1'b0;
        end
        #(PERIOD);
        test_error <= 1'b0;
        #(PERIOD);
        if (true_debug_state != test.permutation_state) begin
            test_error <= 1'b1;
            $display("Final state do not match expected one");
        end else begin
            test_error <= 1'b0;
        end
        #(PERIOD);
        test_verification <= 1'b0;
        test_error <= 1'b0;
        #(PERIOD);
        /// Unwrapping test
        test_key_tag <= {array_max_size{1'b0}};
        
        test_din = 32'h00;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        #(PERIOD);
        
        test_din = 32'h01;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_key_or_nonce(test_key, test_key_size);
        #(PERIOD);
        
        test_din = 32'h02;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_key_or_nonce(test_nonce, test_nonce_size);
        #(PERIOD);
        
        test_din = 32'h04;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        receive_tag(test_key_tag_size, test_key_tag);
        #(PERIOD);
        
        test_din = 32'h01;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_ad(test_ad, test_ad_size);
        #(PERIOD);
        
        test_din = 32'h03;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_pt_receive_ct(true_ct, true_ct_size, test_pt);
        #(PERIOD);
        
        test_din = 32'h05;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_verify_tag(true_tag, true_tag_size, verification_tag);
        #(PERIOD);
        
        while(test_din_ready != 1'b1) begin
            #(PERIOD);
        end
        #(PERIOD);
        test_verification <= 1'b1;
        if (true_key_tag == test_key_tag) begin
            test_error <= 1'b0;
        end else begin
            test_error <= 1'b1;
            $display("Computed key tags do not match expected ones");
        end
        #PERIOD;
        test_error <= 1'b0;
        #PERIOD;
        if (true_pt == test_pt) begin
            test_error <= 1'b0;
        end else begin
            test_error <= 1'b1;
            $display("Computed plaintext do not match expected ones");
        end
        #PERIOD;
        test_error <= 1'b0;
        #PERIOD;
        if ((true_tag_size > 0) && (verification_tag != 32'b0)) begin
            test_error <= 1'b1;
            $display("Tags do not match expected ones");
        end else begin
            test_error <= 1'b0;
        end
        #PERIOD;
        test_error <= 1'b0;
        #PERIOD;
        if (true_debug_state != test.permutation_state) begin
            test_error <= 1'b1;
            $display("Final state do not match expected one");
        end else begin
            test_error <= 1'b0;
        end
        #PERIOD;
        test_verification <= 1'b0;
        test_error <= 1'b0;
        #PERIOD;
        /// Invalid tag unwrapping test
        test_key_tag <= {array_max_size{1'b0}};
        true_tag[0] = true_tag[0] ^ 1'b1;
        
        test_din = 32'h00;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        #(PERIOD);
        
        test_din = 32'h01;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_key_or_nonce(test_key, test_key_size);
        #(PERIOD);
        
        test_din = 32'h02;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_key_or_nonce(test_nonce, test_nonce_size);
        #(PERIOD);
        
        test_din = 32'h04;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 8'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        receive_tag(test_key_tag_size, test_key_tag);
        #(PERIOD);
        
        test_din = 32'h01;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_ad(test_ad, test_ad_size);
        #(PERIOD);
        
        test_din = 32'h03;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_pt_receive_ct(true_ct, true_ct_size, test_pt);
        #(PERIOD);
        
        test_din = 32'h05;
        test_din_valid = 1'b1;
        if(test_din_ready != 1'b1) begin
            #(PERIOD);
            while(test_din_ready != 1'b1) begin
                #(PERIOD);
            end
            #(PERIOD);
        end else begin
            #(PERIOD);
        end
        test_din = 32'h00;
        test_din_valid = 1'b0;
        #(number_of_wait_cycles*PERIOD);
        send_verify_tag(true_tag, true_tag_size, verification_tag);
        #(PERIOD);
        
        while(test_din_ready != 1'b1) begin
            #(PERIOD);
        end
        #(PERIOD);
        test_verification <= 1'b1;
        if (true_key_tag == test_key_tag) begin
            test_error <= 1'b0;
        end else begin
            test_error <= 1'b1;
            $display("Computed key tags do not match expected ones");
        end
        #PERIOD;
        test_error <= 1'b0;
        #PERIOD;
        if (true_pt == test_pt) begin
            test_error <= 1'b0;
        end else begin
            test_error <= 1'b1;
            $display("Computed plaintext do not match expected ones");
        end
        #PERIOD;
        test_error <= 1'b0;
        #PERIOD;
        if ((true_tag_size > 0) && (verification_tag == 32'b0)) begin
            test_error <= 1'b1;
            $display("Tags are matching when they should not");
        end else begin
            test_error <= 1'b0;
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
    $dumpvars(1, tb_friet_ae_protected_32_bits);
end

endmodule