// (c) Copyright 1995-2025 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:axi4_switch_custom:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module axi4_switch_buffered_axi4_switch_custom_0_0 (
  clk,
  rst_n,
  s_req_supress,
  axi_s0_tdata_i,
  axi_s0_tuser_i,
  axi_s0_tlast_i,
  axi_s0_tkeep_i,
  axi_s0_tvalid_i,
  axi_s0_tready_o,
  axi_s1_tdata_i,
  axi_s1_tuser_i,
  axi_s1_tlast_i,
  axi_s1_tkeep_i,
  axi_s1_tvalid_i,
  axi_s1_tready_o,
  axi_m0_tdata_o,
  axi_m0_tuser_o,
  axi_m0_tlast_o,
  axi_m0_tkeep_o,
  axi_m0_tvalid_o,
  axi_m0_tready_i
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF axi_s0_i:axi_s1_i:axi_m0_o, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN axi4_switch_buffered_s_axis_aclk_0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst_n RST" *)
input wire rst_n;
input wire [1 : 0] s_req_supress;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s0_i TDATA" *)
input wire [511 : 0] axi_s0_tdata_i;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s0_i TUSER" *)
input wire [80 : 0] axi_s0_tuser_i;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s0_i TLAST" *)
input wire axi_s0_tlast_i;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s0_i TKEEP" *)
input wire [15 : 0] axi_s0_tkeep_i;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s0_i TVALID" *)
input wire axi_s0_tvalid_i;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_s0_i, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 81, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN axi4_switch_buffered_s_axis_aclk_0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s0_i TREADY" *)
output wire axi_s0_tready_o;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s1_i TDATA" *)
input wire [511 : 0] axi_s1_tdata_i;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s1_i TUSER" *)
input wire [80 : 0] axi_s1_tuser_i;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s1_i TLAST" *)
input wire axi_s1_tlast_i;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s1_i TKEEP" *)
input wire [15 : 0] axi_s1_tkeep_i;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s1_i TVALID" *)
input wire axi_s1_tvalid_i;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_s1_i, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 81, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN axi4_switch_buffered_s_axis_aclk_0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_s1_i TREADY" *)
output wire axi_s1_tready_o;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o TDATA" *)
output wire [511 : 0] axi_m0_tdata_o;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o TUSER" *)
output wire [80 : 0] axi_m0_tuser_o;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o TLAST" *)
output wire axi_m0_tlast_o;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o TKEEP" *)
output wire [15 : 0] axi_m0_tkeep_o;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o TVALID" *)
output wire axi_m0_tvalid_o;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_m0_o, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 81, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN axi4_switch_buffered_s_axis_aclk_0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o TREADY" *)
input wire axi_m0_tready_i;

  axi4_switch_custom #(
    .TDATA_L(512),
    .TUSER_L(81),
    .TKEEP_L(16)
  ) inst (
    .clk(clk),
    .rst_n(rst_n),
    .s_req_supress(s_req_supress),
    .axi_s0_tdata_i(axi_s0_tdata_i),
    .axi_s0_tuser_i(axi_s0_tuser_i),
    .axi_s0_tlast_i(axi_s0_tlast_i),
    .axi_s0_tkeep_i(axi_s0_tkeep_i),
    .axi_s0_tvalid_i(axi_s0_tvalid_i),
    .axi_s0_tready_o(axi_s0_tready_o),
    .axi_s1_tdata_i(axi_s1_tdata_i),
    .axi_s1_tuser_i(axi_s1_tuser_i),
    .axi_s1_tlast_i(axi_s1_tlast_i),
    .axi_s1_tkeep_i(axi_s1_tkeep_i),
    .axi_s1_tvalid_i(axi_s1_tvalid_i),
    .axi_s1_tready_o(axi_s1_tready_o),
    .axi_m0_tdata_o(axi_m0_tdata_o),
    .axi_m0_tuser_o(axi_m0_tuser_o),
    .axi_m0_tlast_o(axi_m0_tlast_o),
    .axi_m0_tkeep_o(axi_m0_tkeep_o),
    .axi_m0_tvalid_o(axi_m0_tvalid_o),
    .axi_m0_tready_i(axi_m0_tready_i)
  );
endmodule
