`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/08/2025 09:37:04 AM
// Design Name: 
// Module Name: tkeep_convertor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tkeep_convertor(
    input  wire [15:0] tkeep_dword,  // from PCIe IP
    output wire [63:0] tkeep_byte    // to FIFO
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : tkeep_expand
            assign tkeep_byte[i*4 +: 4] = {4{tkeep_dword[i]}};
        end
    endgenerate

endmodule

module tkeep_byte_to_dword(
    input  wire [63:0] tkeep_byte,
    output wire [15:0] tkeep_dword
);

    genvar j;
    generate
        for (j = 0; j < 16; j = j + 1) begin : tkeep_collapse
            assign tkeep_dword[j] = |tkeep_byte[j*4 +: 4];
        end
    endgenerate

endmodule