`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2025 06:46:43 AM
// Design Name: 
// Module Name: axi4_switch_custom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: dual input single output axi4 switch 
// 
// Revision 0.01 - First draft
// Additional Comments:
//            1. current implementation assumes symetrical input and output AXI port
//            2. module assumes all ports operate on same clock
//            3. module does not support straddle mode 
//////////////////////////////////////////////////////////////////////////////////


module axi4_switch_custom
#(  
    parameter  TDATA_L = 512, 
    parameter  TUSER_L = 81,
    parameter  TKEEP_L = 16
)(
    input wire       clk,
    input wire       rst_n,
    input wire [1:0] s_req_supress,
       
    //AXI4 slave interface 0 (connect to master)
    input  wire [TDATA_L-1 : 0] axi_s0_tdata_i,
    input  wire [TUSER_L-1 : 0] axi_s0_tuser_i,
    input  wire                 axi_s0_tlast_i,
    input  wire [TKEEP_L-1 : 0] axi_s0_tkeep_i,
    input  wire                 axi_s0_tvalid_i,
    output reg                  axi_s0_tready_o,
    
    //AXI4 slave interface 1
    input  wire [TDATA_L-1 : 0] axi_s1_tdata_i,
    input  wire [TUSER_L-1 : 0] axi_s1_tuser_i,
    input  wire                 axi_s1_tlast_i,
    input  wire [TKEEP_L-1 : 0] axi_s1_tkeep_i,
    input  wire                 axi_s1_tvalid_i,
    output reg                  axi_s1_tready_o,
    
    output reg  [TDATA_L-1 : 0] axi_m0_tdata_o,
    output reg  [TUSER_L-1 : 0] axi_m0_tuser_o,
    output reg                  axi_m0_tlast_o,
    output reg  [TKEEP_L-1 : 0] axi_m0_tkeep_o,
    output reg                  axi_m0_tvalid_o,
    input  wire                 axi_m0_tready_i
    
    );

localparam NUM_IN = 2;


reg [NUM_IN-1 : 0] port_busy; //set to high when tvalid is recieved while tready is high, set to low when tlast is recieved
reg [NUM_IN-1 : 0] port_order; // tracks the last transmission

wire [NUM_IN-1 :0] port_valid;
wire [NUM_IN-1 :0] port_last;

reg [NUM_IN-1 : 0] cur_state;

assign port_valid = {axi_s1_tvalid_i, axi_s0_tvalid_i};
assign port_last  = {axi_s1_tlast_i , axi_s0_tlast_i};

 

always @(*) begin
    axi_s0_tready_o = 1'b0;
    axi_s1_tready_o = 1'b0;
    axi_m0_tlast_o  = 1'b0;
    axi_m0_tvalid_o = 1'b0;
    axi_m0_tdata_o  = {TDATA_L{1'bx}};
    axi_m0_tuser_o  = {TUSER_L{1'b0}};
    axi_m0_tkeep_o  = {TKEEP_L{1'bx}};
    case (cur_state)
        2'b00: begin
            case (port_valid)
                2'b01 : begin
                    axi_s0_tready_o = axi_m0_tready_i;
                    axi_m0_tdata_o  = axi_s0_tdata_i;
                    axi_m0_tuser_o  = axi_s0_tuser_i;
                    axi_m0_tlast_o  = axi_s0_tlast_i;
                    axi_m0_tkeep_o  = axi_s0_tkeep_i;
                    axi_m0_tvalid_o = axi_s0_tvalid_i;
                end
                2'b10 : begin
                    axi_s1_tready_o = axi_m0_tready_i;
                    axi_m0_tdata_o  = axi_s1_tdata_i;
                    axi_m0_tuser_o  = axi_s1_tuser_i;
                    axi_m0_tlast_o  = axi_s1_tlast_i;
                    axi_m0_tkeep_o  = axi_s1_tkeep_i;
                    axi_m0_tvalid_o = axi_s1_tvalid_i;
                end
                2'b11 : begin
                    axi_s0_tready_o = axi_m0_tready_i & port_order[0];
                    axi_s1_tready_o = axi_m0_tready_i & port_order[1];
                    axi_m0_tdata_o  = (port_order[0]) ?  axi_s0_tdata_i : axi_s1_tdata_i;
                    axi_m0_tuser_o  = (port_order[0]) ?  axi_s0_tuser_i : axi_s1_tuser_i;
                    axi_m0_tlast_o  = (port_order[0]) ?  axi_s0_tlast_i : axi_s1_tlast_i;
                    axi_m0_tkeep_o  = (port_order[0]) ?  axi_s0_tkeep_i : axi_s1_tkeep_i;
                    axi_m0_tvalid_o = (port_order[0]) ?  axi_s0_tvalid_i: axi_s1_tvalid_i;
                end
             endcase
        end
        2'b01: begin
            axi_s0_tready_o = axi_m0_tready_i;
            axi_m0_tdata_o  = axi_s0_tdata_i;
            axi_m0_tuser_o  = axi_s0_tuser_i;
            axi_m0_tlast_o  = axi_s0_tlast_i;
            axi_m0_tkeep_o  = axi_s0_tkeep_i;
            axi_m0_tvalid_o = axi_s0_tvalid_i;
         end
         2'b10 : begin
            axi_s1_tready_o = axi_m0_tready_i;
            axi_m0_tdata_o  = axi_s1_tdata_i;
            axi_m0_tuser_o  = axi_s1_tuser_i;
            axi_m0_tlast_o  = axi_s1_tlast_i;
            axi_m0_tkeep_o  = axi_s1_tkeep_i;
            axi_m0_tvalid_o = axi_s1_tvalid_i;
         end
         default : begin
            axi_s0_tready_o = 1'b0;
            axi_s1_tready_o = 1'b0;
         end            
      endcase                            
end

always @(posedge clk) begin
    if (!rst_n) begin
        port_busy  <= 2'b00;
        port_order <= 2'b01;
        cur_state  <= 2'b00;
    end else begin
         case(cur_state)
            2'b00 : begin
                if      (port_valid == 2'b01) begin
                    if (port_last == 2'b00) cur_state <= 2'b01;
                    else port_order <= 2'b10;
                end
                else if (port_valid == 2'b10 ) begin;
                    if (port_last == 2'b00) cur_state <= 2'b10;
                    else port_order <= 2'b01;
                end
                else if (port_valid == 2'b11) begin
                    if (port_order & port_last)begin
                        port_order <= ~ port_order;
                    end else cur_state <= port_order;
                end
            end
            2'b01 : begin
                if (port_last[0]) begin
                    if (port_valid[1] && !port_last[1]) begin
                        cur_state  <= 2'b10;
                    end
                    else begin
                        cur_state  <= 2'b00;
                        port_order <= 2'b10;
                    end
                end
            end
            2'b10 : begin
                if (port_last[1]) begin
                    if (port_valid[0] && !port_last[0]) begin
                        cur_state <= 2'b01;
                    end
                    else begin
                        cur_state  <= 2'b00;
                        port_order <= 2'b01;
                    end
                end
            end
            default : cur_state <= 2'b11;
         endcase
      end
   end        
                       
endmodule
