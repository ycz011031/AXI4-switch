module axi4_straddle_convertor #
(
    parameter integer C_S_AXI_ID_WIDTH        = 4,
    parameter integer C_S_AXI_ADDR_WIDTH      = 32,
    parameter integer C_S_AXI_DATA_WIDTH      = 64,
    parameter integer C_S_AXI_AWUSER_WIDTH    = 1,
    parameter integer C_S_AXI_ARUSER_WIDTH    = 1,
    parameter integer C_S_AXI_WUSER_WIDTH     = 1,
    parameter integer C_S_AXI_RUSER_WIDTH     = 1,
    parameter integer C_S_AXI_BUSER_WIDTH     = 1,
    parameter integer C_M_AXI_ID_WIDTH        = 4,
    parameter integer C_M_AXI_ADDR_WIDTH      = 32,
    parameter integer C_M_AXI_DATA_WIDTH      = 128,
    parameter integer C_M_AXI_AWUSER_WIDTH    = 1,
    parameter integer C_M_AXI_ARUSER_WIDTH    = 1,
    parameter integer C_M_AXI_WUSER_WIDTH     = 1,
    parameter integer C_M_AXI_RUSER_WIDTH     = 1,
    parameter integer C_M_AXI_BUSER_WIDTH     = 1
)
(
    // Global Signals
    input wire                                  ACLK,
    input wire                                  ARESETN,

    // Slave AXI Interface
    input wire [C_S_AXI_ID_WIDTH-1:0]          S_AXI_AWID,
    input wire [C_S_AXI_ADDR_WIDTH-1:0]        S_AXI_AWADDR,
    input wire [7:0]                            S_AXI_AWLEN,
    input wire [2:0]                            S_AXI_AWSIZE,
    input wire [1:0]                            S_AXI_AWBURST,
    input wire [0:0]                            S_AXI_AWLOCK,
    input wire [3:0]                            S_AXI_AWCACHE,
    input wire [2:0]                            S_AXI_AWPROT,
    input wire [3:0]                            S_AXI_AWQOS,
    input wire [C_S_AXI_AWUSER_WIDTH-1:0]      S_AXI_AWUSER,
    input wire                                  S_AXI_AWVALID,
    output wire                                 S_AXI_AWREADY,

    input wire [C_S_AXI_DATA_WIDTH-1:0]        S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1:0]    S_AXI_WSTRB,
    input wire                                  S_AXI_WLAST