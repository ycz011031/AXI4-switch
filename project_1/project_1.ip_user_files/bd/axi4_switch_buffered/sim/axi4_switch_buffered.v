//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.2 (win64) Build 3367213 Tue Oct 19 02:48:09 MDT 2021
//Date        : Tue Jul  8 09:50:06 2025
//Host        : Asus_Zephyrus running 64-bit major release  (build 9200)
//Command     : generate_target axi4_switch_buffered.bd
//Design      : axi4_switch_buffered
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "axi4_switch_buffered,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=axi4_switch_buffered,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=6,numReposBlks=6,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=3,numPkgbdBlks=0,bdsource=USER,da_clkrst_cnt=1,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "axi4_switch_buffered.hwdef" *) 
module axi4_switch_buffered
   (S_AXIS_0_tdata,
    S_AXIS_0_tkeep,
    S_AXIS_0_tlast,
    S_AXIS_0_tready,
    S_AXIS_0_tuser,
    S_AXIS_0_tvalid,
    S_AXIS_1_tdata,
    S_AXIS_1_tkeep,
    S_AXIS_1_tlast,
    S_AXIS_1_tready,
    S_AXIS_1_tuser,
    S_AXIS_1_tvalid,
    axi_m0_o_0_tdata,
    axi_m0_o_0_tkeep,
    axi_m0_o_0_tlast,
    axi_m0_o_0_tready,
    axi_m0_o_0_tuser,
    axi_m0_o_0_tvalid,
    s_axis_aclk_0,
    s_axis_aresetn_0);
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_0, CLK_DOMAIN axi4_switch_buffered_s_axis_aclk_0, FREQ_HZ 100000000, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 81" *) input [511:0]S_AXIS_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_0 TKEEP" *) input [63:0]S_AXIS_0_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_0 TLAST" *) input S_AXIS_0_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_0 TREADY" *) output S_AXIS_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_0 TUSER" *) input [80:0]S_AXIS_0_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_0 TVALID" *) input S_AXIS_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_1 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_1, CLK_DOMAIN axi4_switch_buffered_s_axis_aclk_0, FREQ_HZ 100000000, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 81" *) input [511:0]S_AXIS_1_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_1 TKEEP" *) input [63:0]S_AXIS_1_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_1 TLAST" *) input S_AXIS_1_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_1 TREADY" *) output S_AXIS_1_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_1 TUSER" *) input [80:0]S_AXIS_1_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_1 TVALID" *) input S_AXIS_1_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o_0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_m0_o_0, CLK_DOMAIN axi4_switch_buffered_s_axis_aclk_0, FREQ_HZ 100000000, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 81" *) output [511:0]axi_m0_o_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o_0 TKEEP" *) output [15:0]axi_m0_o_0_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o_0 TLAST" *) output axi_m0_o_0_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o_0 TREADY" *) input axi_m0_o_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o_0 TUSER" *) output [80:0]axi_m0_o_0_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axi_m0_o_0 TVALID" *) output axi_m0_o_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.S_AXIS_ACLK_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.S_AXIS_ACLK_0, ASSOCIATED_BUSIF axi_m0_o_0:S_AXIS_0:S_AXIS_1, ASSOCIATED_RESET s_axis_aresetn_0, CLK_DOMAIN axi4_switch_buffered_s_axis_aclk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input s_axis_aclk_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.S_AXIS_ARESETN_0 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.S_AXIS_ARESETN_0, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input s_axis_aresetn_0;

  wire [511:0]S_AXIS_0_1_TDATA;
  wire [63:0]S_AXIS_0_1_TKEEP;
  wire S_AXIS_0_1_TLAST;
  wire S_AXIS_0_1_TREADY;
  wire [80:0]S_AXIS_0_1_TUSER;
  wire S_AXIS_0_1_TVALID;
  wire [511:0]S_AXIS_1_1_TDATA;
  wire [63:0]S_AXIS_1_1_TKEEP;
  wire S_AXIS_1_1_TLAST;
  wire S_AXIS_1_1_TREADY;
  wire [80:0]S_AXIS_1_1_TUSER;
  wire S_AXIS_1_1_TVALID;
  wire [511:0]axi4_switch_custom_0_axi_m0_o_TDATA;
  wire [15:0]axi4_switch_custom_0_axi_m0_o_TKEEP;
  wire axi4_switch_custom_0_axi_m0_o_TLAST;
  wire axi4_switch_custom_0_axi_m0_o_TREADY;
  wire [80:0]axi4_switch_custom_0_axi_m0_o_TUSER;
  wire axi4_switch_custom_0_axi_m0_o_TVALID;
  wire [511:0]axis_data_fifo_0_M_AXIS_TDATA;
  wire axis_data_fifo_0_M_AXIS_TLAST;
  wire axis_data_fifo_0_M_AXIS_TREADY;
  wire [80:0]axis_data_fifo_0_M_AXIS_TUSER;
  wire axis_data_fifo_0_M_AXIS_TVALID;
  wire [63:0]axis_data_fifo_0_m_axis_tkeep;
  wire [511:0]axis_data_fifo_1_M_AXIS_TDATA;
  wire axis_data_fifo_1_M_AXIS_TLAST;
  wire axis_data_fifo_1_M_AXIS_TREADY;
  wire [80:0]axis_data_fifo_1_M_AXIS_TUSER;
  wire axis_data_fifo_1_M_AXIS_TVALID;
  wire [63:0]axis_data_fifo_1_m_axis_tkeep;
  wire s_axis_aclk_0_1;
  wire s_axis_aresetn_0_1;
  wire [15:0]tkeep_byte_to_dword_0_tkeep_dword;
  wire [15:0]tkeep_byte_to_dword_1_tkeep_dword;
  wire [1:0]xlconstant_0_dout;

  assign S_AXIS_0_1_TDATA = S_AXIS_0_tdata[511:0];
  assign S_AXIS_0_1_TKEEP = S_AXIS_0_tkeep[63:0];
  assign S_AXIS_0_1_TLAST = S_AXIS_0_tlast;
  assign S_AXIS_0_1_TUSER = S_AXIS_0_tuser[80:0];
  assign S_AXIS_0_1_TVALID = S_AXIS_0_tvalid;
  assign S_AXIS_0_tready = S_AXIS_0_1_TREADY;
  assign S_AXIS_1_1_TDATA = S_AXIS_1_tdata[511:0];
  assign S_AXIS_1_1_TKEEP = S_AXIS_1_tkeep[63:0];
  assign S_AXIS_1_1_TLAST = S_AXIS_1_tlast;
  assign S_AXIS_1_1_TUSER = S_AXIS_1_tuser[80:0];
  assign S_AXIS_1_1_TVALID = S_AXIS_1_tvalid;
  assign S_AXIS_1_tready = S_AXIS_1_1_TREADY;
  assign axi4_switch_custom_0_axi_m0_o_TREADY = axi_m0_o_0_tready;
  assign axi_m0_o_0_tdata[511:0] = axi4_switch_custom_0_axi_m0_o_TDATA;
  assign axi_m0_o_0_tkeep[15:0] = axi4_switch_custom_0_axi_m0_o_TKEEP;
  assign axi_m0_o_0_tlast = axi4_switch_custom_0_axi_m0_o_TLAST;
  assign axi_m0_o_0_tuser[80:0] = axi4_switch_custom_0_axi_m0_o_TUSER;
  assign axi_m0_o_0_tvalid = axi4_switch_custom_0_axi_m0_o_TVALID;
  assign s_axis_aclk_0_1 = s_axis_aclk_0;
  assign s_axis_aresetn_0_1 = s_axis_aresetn_0;
  axi4_switch_buffered_axi4_switch_custom_0_0 axi4_switch_custom_0
       (.axi_m0_tdata_o(axi4_switch_custom_0_axi_m0_o_TDATA),
        .axi_m0_tkeep_o(axi4_switch_custom_0_axi_m0_o_TKEEP),
        .axi_m0_tlast_o(axi4_switch_custom_0_axi_m0_o_TLAST),
        .axi_m0_tready_i(axi4_switch_custom_0_axi_m0_o_TREADY),
        .axi_m0_tuser_o(axi4_switch_custom_0_axi_m0_o_TUSER),
        .axi_m0_tvalid_o(axi4_switch_custom_0_axi_m0_o_TVALID),
        .axi_s0_tdata_i(axis_data_fifo_0_M_AXIS_TDATA),
        .axi_s0_tkeep_i(tkeep_byte_to_dword_0_tkeep_dword),
        .axi_s0_tlast_i(axis_data_fifo_0_M_AXIS_TLAST),
        .axi_s0_tready_o(axis_data_fifo_0_M_AXIS_TREADY),
        .axi_s0_tuser_i(axis_data_fifo_0_M_AXIS_TUSER),
        .axi_s0_tvalid_i(axis_data_fifo_0_M_AXIS_TVALID),
        .axi_s1_tdata_i(axis_data_fifo_1_M_AXIS_TDATA),
        .axi_s1_tkeep_i(tkeep_byte_to_dword_1_tkeep_dword),
        .axi_s1_tlast_i(axis_data_fifo_1_M_AXIS_TLAST),
        .axi_s1_tready_o(axis_data_fifo_1_M_AXIS_TREADY),
        .axi_s1_tuser_i(axis_data_fifo_1_M_AXIS_TUSER),
        .axi_s1_tvalid_i(axis_data_fifo_1_M_AXIS_TVALID),
        .clk(s_axis_aclk_0_1),
        .rst_n(s_axis_aresetn_0_1),
        .s_req_supress(xlconstant_0_dout));
  axi4_switch_buffered_axis_data_fifo_0_1 axis_data_fifo_0
       (.m_axis_tdata(axis_data_fifo_0_M_AXIS_TDATA),
        .m_axis_tkeep(axis_data_fifo_0_m_axis_tkeep),
        .m_axis_tlast(axis_data_fifo_0_M_AXIS_TLAST),
        .m_axis_tready(axis_data_fifo_0_M_AXIS_TREADY),
        .m_axis_tuser(axis_data_fifo_0_M_AXIS_TUSER),
        .m_axis_tvalid(axis_data_fifo_0_M_AXIS_TVALID),
        .s_axis_aclk(s_axis_aclk_0_1),
        .s_axis_aresetn(s_axis_aresetn_0_1),
        .s_axis_tdata(S_AXIS_0_1_TDATA),
        .s_axis_tkeep(S_AXIS_0_1_TKEEP),
        .s_axis_tlast(S_AXIS_0_1_TLAST),
        .s_axis_tready(S_AXIS_0_1_TREADY),
        .s_axis_tuser(S_AXIS_0_1_TUSER),
        .s_axis_tvalid(S_AXIS_0_1_TVALID));
  axi4_switch_buffered_axis_data_fifo_0_2 axis_data_fifo_1
       (.m_axis_tdata(axis_data_fifo_1_M_AXIS_TDATA),
        .m_axis_tkeep(axis_data_fifo_1_m_axis_tkeep),
        .m_axis_tlast(axis_data_fifo_1_M_AXIS_TLAST),
        .m_axis_tready(axis_data_fifo_1_M_AXIS_TREADY),
        .m_axis_tuser(axis_data_fifo_1_M_AXIS_TUSER),
        .m_axis_tvalid(axis_data_fifo_1_M_AXIS_TVALID),
        .s_axis_aclk(s_axis_aclk_0_1),
        .s_axis_aresetn(s_axis_aresetn_0_1),
        .s_axis_tdata(S_AXIS_1_1_TDATA),
        .s_axis_tkeep(S_AXIS_1_1_TKEEP),
        .s_axis_tlast(S_AXIS_1_1_TLAST),
        .s_axis_tready(S_AXIS_1_1_TREADY),
        .s_axis_tuser(S_AXIS_1_1_TUSER),
        .s_axis_tvalid(S_AXIS_1_1_TVALID));
  axi4_switch_buffered_tkeep_byte_to_dword_0_0 tkeep_byte_to_dword_0
       (.tkeep_byte(axis_data_fifo_0_m_axis_tkeep),
        .tkeep_dword(tkeep_byte_to_dword_0_tkeep_dword));
  axi4_switch_buffered_tkeep_byte_to_dword_1_0 tkeep_byte_to_dword_1
       (.tkeep_byte(axis_data_fifo_1_m_axis_tkeep),
        .tkeep_dword(tkeep_byte_to_dword_1_tkeep_dword));
  axi4_switch_buffered_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
endmodule
