/**
 Implementation by Pedro Maat C. Massolino,
 hereby denoted as "the implementer".

 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
*/
module friet_permutation_protected_n_rounds_axi4_lite(aclk, aresetn, s_axi_awaddr, s_axi_awprot, s_axi_awvalid, s_axi_awready, s_axi_wdata, s_axi_wstrb, s_axi_wvalid, s_axi_wready, s_axi_bresp, s_axi_bvalid, s_axi_bready, s_axi_araddr, s_axi_arprot, s_axi_arvalid, s_axi_arready, s_axi_rdata, s_axi_rresp, s_axi_rvalid, s_axi_rready);

parameter COMBINATIONAL_ROUNDS = 1;

input aclk;
input aresetn;
// Write Address related signals
input [3:0] s_axi_awaddr;
input [2:0] s_axi_awprot;
input s_axi_awvalid;
output s_axi_awready;
// Write data signals
input [31:0] s_axi_wdata;
input [3:0] s_axi_wstrb;
input s_axi_wvalid;
output s_axi_wready;
// Response channel
output [1:0] s_axi_bresp;
output s_axi_bvalid;
input s_axi_bready;
// Read Address related signals
input [3:0] s_axi_araddr;
input [2:0] s_axi_arprot;
input s_axi_arvalid;
output s_axi_arready;
// Read data signals
output [31:0] s_axi_rdata;
output [1:0] s_axi_rresp;
output s_axi_rvalid;
input s_axi_rready;

reg [3:0] reg_s_axi_awaddr;
reg [2:0] reg_s_axi_awprot;
reg reg_s_axi_awvalid;
reg reg_s_axi_awready;

reg reg_s_axi_awaddr_is_good;

reg [31:0] reg_s_axi_wdata;
reg [3:0] reg_s_axi_wstrb;
reg reg_s_axi_wvalid;
reg reg_s_axi_wready;

reg [1:0] reg_s_axi_bresp;
reg reg_s_axi_bvalid;

reg [3:0] reg_s_axi_araddr;
reg [2:0] reg_s_axi_arprot;
reg reg_s_axi_arvalid;
reg reg_s_axi_arready;

reg reg_s_axi_araddr_is_good;

reg [31:0] reg_s_axi_rdata;
reg [1:0] reg_s_axi_rresp;
reg reg_s_axi_rvalid;

reg permutation_start_enable;
reg permutation_state_buffer_in_enabled;
wire [31:0] permutation_state_buffer_in;
reg permutation_state_buffer_out_enabled;
wire [383:0] permutation_state_buffer;
wire permutation_core_free;
wire permutation_core_finish;
wire permutation_fault_detected;


assign s_axi_awready = reg_s_axi_awready;

assign s_axi_wready  = reg_s_axi_wready;

assign s_axi_bresp   = reg_s_axi_bresp;
assign s_axi_bvalid  = reg_s_axi_bvalid;

assign s_axi_arready = reg_s_axi_arready;

assign s_axi_rdata   = reg_s_axi_rdata;
assign s_axi_rresp   = reg_s_axi_rresp;
assign s_axi_rvalid  = reg_s_axi_rvalid;

// Input registers for Write address

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_awaddr <= 4'b0;
    end else if (s_axi_awvalid == 1'b1) begin
        reg_s_axi_awaddr <= s_axi_awaddr;
    end
end

always @(*) begin
    case(reg_s_axi_awaddr)
        // Valid writing addresses
        4'h4 : begin
            reg_s_axi_awaddr_is_good = 1'b1;
        end
        4'h8 : begin
            reg_s_axi_awaddr_is_good = 1'b1;
        end
        default: begin // Not valid address
            reg_s_axi_awaddr_is_good = 1'b0;
        end
    endcase
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_awprot <= 3'b0;
    end else if (s_axi_awvalid == 1'b1) begin
        reg_s_axi_awprot <= s_axi_awprot;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_awvalid <= 1'b0;
    end else if ((reg_s_axi_awvalid == 1'b0) || (reg_s_axi_wvalid == 1'b1)) begin
        reg_s_axi_awvalid <= s_axi_awvalid;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_awready <= 1'b0;
    end else begin
        if(permutation_core_free == 1'b0) begin
            reg_s_axi_awready <= 1'b0;
        end else begin
            reg_s_axi_awready <= 1'b1;
        end
    end
end

// Input registers for Write data

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_wdata <= 32'b0;
    end else if (s_axi_wvalid == 1'b1) begin
        reg_s_axi_wdata <= s_axi_wdata;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_wstrb <= 4'b0;
    end else if (s_axi_wvalid == 1'b1) begin
        reg_s_axi_wstrb <= s_axi_wstrb;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_wvalid <= 1'b0;
    end else if ((reg_s_axi_wvalid == 1'b0) || (reg_s_axi_awvalid == 1'b1)) begin
        reg_s_axi_wvalid <= s_axi_wvalid;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_wready <= 1'b0;
    end else begin
        if(permutation_core_free == 1'b0) begin
            reg_s_axi_wready <= 1'b0;
        end else begin
            reg_s_axi_wready <= 1'b1;
        end
    end
end

// Response channel

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_bresp <= 2'b00;
    end else if ((reg_s_axi_awvalid == 1'b1) && (reg_s_axi_wvalid == 1'b1)) begin
        if (reg_s_axi_awaddr_is_good == 1'b0) begin
            reg_s_axi_bresp <= 2'b10;
        end else begin
            reg_s_axi_bresp <= 2'b00;
        end
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_bvalid <= 1'b0;
    end else begin 
        if ((reg_s_axi_awvalid == 1'b1) && (reg_s_axi_wvalid == 1'b1)) begin
            reg_s_axi_bvalid <= 1'b1;
        end else if ((reg_s_axi_bvalid == 1'b1) && (s_axi_bready == 1'b1)) begin
            reg_s_axi_bvalid <= 1'b0;
        end
    end
end

// Read Address related signals

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_araddr <= 4'b0;
    end else if (s_axi_arvalid == 1'b1) begin
        reg_s_axi_araddr <= s_axi_araddr;
    end
end

always @(*) begin
    case(reg_s_axi_araddr)
        // Valid reading addresses
        4'h0 : begin
            reg_s_axi_araddr_is_good = 1'b1;
        end
        4'hB : begin
            reg_s_axi_araddr_is_good = 1'b1;
        end
        default: begin // Not valid address
            reg_s_axi_araddr_is_good = 1'b0;
        end
    endcase
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_arprot <= 3'b0;
    end else if (s_axi_arvalid == 1'b1) begin
        reg_s_axi_arprot <= s_axi_arprot;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_arvalid <= 1'b0;
    end else begin
        reg_s_axi_arvalid <= s_axi_arvalid;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_arready <= 1'b0;
    end else begin
        if(permutation_core_free == 1'b0) begin
            reg_s_axi_arready <= 1'b0;
        end else begin
            reg_s_axi_arready <= 1'b1;
        end
    end
end

// Read Data related signals

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_rdata <= 32'b0;
    end else begin
        if (reg_s_axi_arvalid == 1'b1) begin
            if (reg_s_axi_araddr == 4'h0) begin
                reg_s_axi_rdata <= permutation_state_buffer[31:0];
            end else if (reg_s_axi_araddr == 4'hB) begin
                reg_s_axi_rdata <= {31'b0,permutation_fault_detected};
            end else begin
                reg_s_axi_rdata <= 32'b0;
            end
        end
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_rresp <= 2'b0;
    end else if (reg_s_axi_arvalid == 1'b1) begin
        if(reg_s_axi_araddr_is_good == 1'b0) begin
            reg_s_axi_rresp <= 2'b10;
        end else begin
            reg_s_axi_rresp <= 2'b00;
        end
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_rvalid <= 1'b0;
    end else begin
        if (reg_s_axi_arvalid == 1'b1) begin
            reg_s_axi_rvalid <= 1'b1;
        end else if (reg_s_axi_rvalid == 1'b1 && s_axi_rready == 1'b1) begin
            reg_s_axi_rvalid <= 1'b0;
        end
    end
end

always @(*) begin
    if((reg_s_axi_awaddr == 4'h8) && (reg_s_axi_awvalid == 1'b1) && (reg_s_axi_wvalid == 1'b1)) begin
        permutation_start_enable = 1'b1;
    end else begin
        permutation_start_enable = 1'b0;
    end
end

always @(*) begin
    if((reg_s_axi_awaddr == 4'h4) && (reg_s_axi_awvalid == 1'b1) && (reg_s_axi_wvalid == 1'b1)) begin
        permutation_state_buffer_in_enabled = 1'b1;
    end else begin
        permutation_state_buffer_in_enabled = 1'b0;
    end
end

always @(*) begin
    if((reg_s_axi_araddr == 4'h0) && (reg_s_axi_rvalid == 1'b1)) begin
        permutation_state_buffer_out_enabled = 1'b1;
    end else begin
        permutation_state_buffer_out_enabled = 1'b0;
    end
end

assign permutation_state_buffer_in = reg_s_axi_wdata;

friet_permutation_protected_n_rounds_no_communication
#(.BUFFER_LENGTH(32),
.COMBINATIONAL_ROUNDS(COMBINATIONAL_ROUNDS))
permutation(
    .clk(aclk),
    .aresetn(aresetn),
    .start_enable(permutation_start_enable),
    .state_buffer_in_enabled(permutation_state_buffer_in_enabled),
    .state_buffer_in(permutation_state_buffer_in),
    .state_buffer_out_enabled(permutation_state_buffer_out_enabled),
    .state_buffer(permutation_state_buffer),
    .core_free(permutation_core_free),
    .core_finish(permutation_core_finish),
    .fault_detected(permutation_fault_detected)
);

endmodule