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


module axi4_switch_custom_31
#(  
    parameter  TDATA_L = 512, 
    parameter  TUSER_L = 81,
    parameter  TKEEP_L = 16
)(
    input wire       clk,
    input wire       rst_n,
    input wire [1:0] s_req_supress,
       
    // AXI4-Stream slave interface 0 (connects to master)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s0_i TDATA"  *)
    input  wire [TDATA_L-1 : 0] axi_s0_tdata_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s0_i TUSER"  *)
    input  wire [TUSER_L-1 : 0] axi_s0_tuser_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s0_i TLAST"  *)
    input  wire                 axi_s0_tlast_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s0_i TKEEP"  *)
    input  wire [TKEEP_L-1 : 0] axi_s0_tkeep_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s0_i TVALID" *)
    input  wire                 axi_s0_tvalid_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s0_i TREADY" *)
    output reg                  axi_s0_tready_o,
    
    // AXI4-Stream slave interface 1
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s1_i TDATA"  *)
    input  wire [TDATA_L-1 : 0] axi_s1_tdata_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s1_i TUSER"  *)
    input  wire [TUSER_L-1 : 0] axi_s1_tuser_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s1_i TLAST"  *)
    input  wire                 axi_s1_tlast_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s1_i TKEEP"  *)
    input  wire [TKEEP_L-1 : 0] axi_s1_tkeep_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s1_i TVALID" *)
    input  wire                 axi_s1_tvalid_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s1_i TREADY" *)
    output reg                  axi_s1_tready_o,
    
    // AXI4-Stream slave interface 2
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s2_i TDATA"  *)
    input  wire [TDATA_L-1 : 0] axi_s2_tdata_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s2_i TUSER"  *)
    input  wire [TUSER_L-1 : 0] axi_s2_tuser_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s2_i TLAST"  *)
    input  wire                 axi_s2_tlast_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s2_i TKEEP"  *)
    input  wire [TKEEP_L-1 : 0] axi_s2_tkeep_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s2_i TVALID" *)
    input  wire                 axi_s2_tvalid_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s2_i TREADY" *)
    output reg                  axi_s2_tready_o,

    // AXI4-Stream master interface 0 (output)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o TDATA"  *)
    output reg  [TDATA_L-1 : 0] axi_m0_tdata_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o TUSER"  *)
    output reg  [TUSER_L-1 : 0] axi_m0_tuser_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o TLAST"  *)
    output reg                  axi_m0_tlast_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o TKEEP"  *)
    output reg  [TKEEP_L-1 : 0] axi_m0_tkeep_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o TVALID" *)
    output reg                  axi_m0_tvalid_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o TREADY" *)
    input  wire                 axi_m0_tready_i
);

localparam NUM_IN = 3;

localparam idle = 3'b000;
localparam tx_1 = 3'b001;
localparam tx_2 = 3'b010;
localparam tx_3 = 3'b100;

reg [NUM_IN-1 : 0] port_order; // tracks the last transmission
reg [NUM_IN-1 : 0] cur_state; // Current state

wire [NUM_IN-1 :0] port_valid;
wire [NUM_IN-1 :0] port_last;


assign port_valid = {axi_s2_tvalid_i, axi_s1_tvalid_i, axi_s0_tvalid_i};
assign port_last  = {axi_s2_tlast_i, axi_s1_tlast_i , axi_s0_tlast_i};

always @(*) begin
    axi_s0_tready_o = 1'b0;
    axi_s1_tready_o = 1'b0;
    axi_s2_tready_o = 1'b0;
    axi_m0_tlast_o  = 1'b0;
    axi_m0_tvalid_o = 1'b0;
    axi_m0_tdata_o  = {TDATA_L{1'bx}};
    axi_m0_tuser_o  = {TUSER_L{1'b0}};
    axi_m0_tkeep_o  = {TKEEP_L{1'bx}};
    case (cur_state)
        idle : begin
            case (port_valid)
                3'b001: begin
                    axi_s0_tready_o = axi_m0_tready_i;
                    axi_m0_tdata_o  = axi_s0_tdata_i;
                    axi_m0_tuser_o  = axi_s0_tuser_i;
                    axi_m0_tlast_o  = axi_s0_tlast_i;
                    axi_m0_tkeep_o  = axi_s0_tkeep_i;
                    axi_m0_tvalid_o = axi_s0_tvalid_i;
                end
                3'b010 : begin
                    axi_s1_tready_o = axi_m0_tready_i;
                    axi_m0_tdata_o  = axi_s1_tdata_i;
                    axi_m0_tuser_o  = axi_s1_tuser_i;
                    axi_m0_tlast_o  = axi_s1_tlast_i;
                    axi_m0_tkeep_o  = axi_s1_tkeep_i;
                    axi_m0_tvalid_o = axi_s1_tvalid_i;
                end
                3'b100 : begin
                    axi_s2_tready_o = axi_m0_tready_i;
                    axi_m0_tdata_o  = axi_s2_tdata_i;
                    axi_m0_tuser_o  = axi_s2_tuser_i;
                    axi_m0_tlast_o  = axi_s2_tlast_i;
                    axi_m0_tkeep_o  = axi_s2_tkeep_i;
                    axi_m0_tvalid_o = axi_s2_tvalid_i;
                end
                3'b011 : begin
                    axi_s0_tready_o = axi_m0_tready_i & !port_order[1];
                    axi_s1_tready_o = axi_m0_tready_i &  port_order[1];
                    axi_m0_tdata_o  = (port_order[1]) ?  axi_s1_tdata_i : axi_s0_tdata_i;
                    axi_m0_tuser_o  = (port_order[1]) ?  axi_s1_tuser_i : axi_s0_tuser_i;
                    axi_m0_tlast_o  = (port_order[1]) ?  axi_s1_tlast_i : axi_s0_tlast_i;
                    axi_m0_tkeep_o  = (port_order[1]) ?  axi_s1_tkeep_i : axi_s0_tkeep_i;
                    axi_m0_tvalid_o = (port_order[1]) ?  axi_s1_tvalid_i: axi_s0_tvalid_i;
                end
                3'b110 : begin
                    axi_s1_tready_o = axi_m0_tready_i & !port_order[2];
                    axi_s2_tready_o = axi_m0_tready_i &  port_order[2];
                    axi_m0_tdata_o  = (port_order[2]) ?  axi_s2_tdata_i : axi_s1_tdata_i;
                    axi_m0_tuser_o  = (port_order[2]) ?  axi_s2_tuser_i : axi_s1_tuser_i;
                    axi_m0_tlast_o  = (port_order[2]) ?  axi_s2_tlast_i : axi_s1_tlast_i;
                    axi_m0_tkeep_o  = (port_order[2]) ?  axi_s2_tkeep_i : axi_s1_tkeep_i;
                    axi_m0_tvalid_o = (port_order[2]) ?  axi_s2_tvalid_i: axi_s1_tvalid_i;
                end
                3'b101 : begin
                    axi_s2_tready_o = axi_m0_tready_i & !port_order[0];
                    axi_s0_tready_o = axi_m0_tready_i &  port_order[0];
                    axi_m0_tdata_o  = (port_order[0]) ?  axi_s0_tdata_i : axi_s2_tdata_i;
                    axi_m0_tuser_o  = (port_order[0]) ?  axi_s0_tuser_i : axi_s2_tuser_i;
                    axi_m0_tlast_o  = (port_order[0]) ?  axi_s0_tlast_i : axi_s2_tlast_i;
                    axi_m0_tkeep_o  = (port_order[0]) ?  axi_s0_tkeep_i : axi_s2_tkeep_i;
                    axi_m0_tvalid_o = (port_order[0]) ?  axi_s0_tvalid_i: axi_s2_tvalid_i;
                end
                3'b111 : begin
                    axi_s0_tready_o = axi_m0_tready_i & port_order[0];
                    axi_s1_tready_o = axi_m0_tready_i & port_order[1];
                    axi_s2_tready_o = axi_m0_tready_i & port_order[2];
                    axi_m0_tdata_o  = (port_order[0]) ?  axi_s0_tdata_i : (port_order[1]? axi_s1_tdata_i : axi_s2_tdata_i);
                    axi_m0_tuser_o  = (port_order[0]) ?  axi_s0_tuser_i : (port_order[1]? axi_s1_tuser_i : axi_s2_tuser_i);
                    axi_m0_tlast_o  = (port_order[0]) ?  axi_s0_tlast_i : (port_order[1]? axi_s1_tlast_i : axi_s2_tlast_i);
                    axi_m0_tkeep_o  = (port_order[0]) ?  axi_s0_tkeep_i : (port_order[1]? axi_s1_tkeep_i : axi_s2_tkeep_i);
                    axi_m0_tvalid_o = (port_order[0]) ?  axi_s0_tvalid_i: (port_order[1]? axi_s1_tvalid_i: axi_s2_tvalid_i);
               end
          endcase
        end
        tx_1 : begin
            axi_s0_tready_o = axi_m0_tready_i;
            axi_m0_tdata_o  = axi_s0_tdata_i;
            axi_m0_tuser_o  = axi_s0_tuser_i;
            axi_m0_tlast_o  = axi_s0_tlast_i;
            axi_m0_tkeep_o  = axi_s0_tkeep_i;
            axi_m0_tvalid_o = axi_s0_tvalid_i;
        end
        tx_2 : begin
            axi_s1_tready_o = axi_m0_tready_i;
            axi_m0_tdata_o  = axi_s1_tdata_i;
            axi_m0_tuser_o  = axi_s1_tuser_i;
            axi_m0_tlast_o  = axi_s1_tlast_i;
            axi_m0_tkeep_o  = axi_s1_tkeep_i;
            axi_m0_tvalid_o = axi_s1_tvalid_i;
        end
        tx_3 : begin
            axi_s2_tready_o = axi_m0_tready_i;
            axi_m0_tdata_o  = axi_s2_tdata_i;
            axi_m0_tuser_o  = axi_s2_tuser_i;
            axi_m0_tlast_o  = axi_s2_tlast_i;
            axi_m0_tkeep_o  = axi_s2_tkeep_i;
            axi_m0_tvalid_o = axi_s2_tvalid_i;
        end
        default : begin
            axi_s0_tready_o = 1'b0;
            axi_s1_tready_o = 1'b0;
            axi_s2_tready_o = 1'b0;
            axi_m0_tvalid_o = 1'b0;
        end
    endcase
end

always @(posedge clk) begin
    if (!rst_n) begin
        cur_state <= 3'b000;
        port_order<= 3'b001;
    end else begin
        case(cur_state)
            idle : begin
                case (port_valid)
                    3'b001: begin
                        if (port_last[0] != 1'b1) cur_state <= tx_1;
                        else port_order <= 3'b010;
                    end
                    3'b010: begin
                        if (port_last[1] != 1'b1) cur_state <= tx_2;
                        else port_order <= 3'b100;
                    end
                    3'b100: begin
                        if (port_last[2] != 1'b1) cur_state <= tx_3;
                        else port_order <= 3'b001;
                    end
                    3'b011: begin
                        if (port_order[1] == 1'b1) begin
                            if (port_last[1] != 1'b1) cur_state <= tx_2;
                            else port_order <= 3'b100;
                        end else begin
                            if (port_last[0] != 1'b1) cur_state <= tx_1;
                            else port_order <= 3'b010;
                        end
                    end
                    3'b110: begin
                        if (port_order[2] == 1'b1) begin
                            if (port_last[2] != 1'b1) cur_state <= tx_3;
                            else port_order <= 3'b001;
                        end else begin
                            if (port_last[1] != 1'b1) cur_state <= tx_2;
                            else port_order <= 3'b100;
                        end
                    end
                    3'b101: begin
                        if (port_order[0] == 1'b1) begin
                            if (port_last[0] != 1'b1) cur_state <= tx_1;
                            else port_order <= 3'b010;
                        end else begin
                            if (port_last[2] != 1'b1) cur_state <= tx_3;
                            else port_order <= 3'b001;
                        end 
                    end
                    3'b111 : begin
                        if (port_order & port_last) begin
                            case (port_order)
                                3'b001 : port_order <= 3'b010;
                                3'b010 : port_order <= 3'b100;
                                3'b100 : port_order <= 3'b001;
                                default: port_order <= 3'b001;
                            endcase
                        end else cur_state <= port_order;
                    end
                    default : cur_state <= cur_state;
                endcase
            end
            tx_1 : begin
                if (port_last[0]) begin
                    if(port_valid[1] && !port_last[1])begin
                        cur_state <= tx_2;
                    end else if (!port_valid[1] && port_valid[2] && !port_last[2])begin
                        cur_state <= tx_3;
                    end else begin
                        cur_state <= idle;
                        port_order<= 3'b010;
                    end
                end
            end
            tx_2 : begin
                if (port_last[1]) begin
                    if(port_valid[2] && !port_last[2])begin
                        cur_state <= tx_3;
                    end else if (!port_valid[2] && port_valid[0] && !port_last[0])begin
                        cur_state <= tx_1;
                    end else begin
                        cur_state <= idle;
                        port_order <= 3'b100;
                    end
                end
            end
            tx_3 : begin
                if (port_last[2]) begin
                    if(port_valid[0] && !port_last[0])begin
                        cur_state <= tx_1;
                    end else if (!port_valid[0] && port_valid[1] && !port_last[1] )begin
                        cur_state <= tx_2;
                    end else begin
                        cur_state <= idle;
                        port_order <= 3'b001;
                    end 
                end
            end
            default : cur_state <= 3'b111;
        endcase
    end
end

endmodule