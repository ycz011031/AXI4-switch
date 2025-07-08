`timescale 1ns / 1ps

module axi4_switch_custom_tb();

  // Parameters
  localparam TDATA_L = 512;
  localparam TUSER_L = 81;
  localparam TKEEP_L = 16;

  // Clock and reset
  reg clk = 0;
  reg rst_n = 0;
  always #5 clk = ~clk; // 100 MHz clock

  // AXI4-Stream signals
  reg  [TDATA_L-1:0] axi_s0_tdata_i;
  reg  [TUSER_L-1:0] axi_s0_tuser_i;
  reg                axi_s0_tlast_i;
  reg  [TKEEP_L-1:0] axi_s0_tkeep_i;
  reg                axi_s0_tvalid_i;
  wire               axi_s0_tready_o;

  reg  [TDATA_L-1:0] axi_s1_tdata_i;
  reg  [TUSER_L-1:0] axi_s1_tuser_i;
  reg                axi_s1_tlast_i;
  reg  [TKEEP_L-1:0] axi_s1_tkeep_i;
  reg                axi_s1_tvalid_i;
  wire               axi_s1_tready_o;

  wire [TDATA_L-1:0] axi_m0_tdata_o;
  wire [TUSER_L-1:0] axi_m0_tuser_o;
  wire               axi_m0_tlast_o;
  wire [TKEEP_L-1:0] axi_m0_tkeep_o;
  wire               axi_m0_tvalid_o;
  reg                axi_m0_tready_i = 1;

  reg  [1:0] s_req_supress = 2'b00;

  // DUT instance
  axi4_switch_custom #(
    .TDATA_L(TDATA_L),
    .TUSER_L(TUSER_L),
    .TKEEP_L(TKEEP_L)
  ) dut (
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

  task send_packet(input integer port, input integer beats);
    integer i;
    begin
      for (i = 0; i < beats; i = i + 1) begin
        if (port == 0) begin
          axi_s0_tdata_i  = $random;
          axi_s0_tuser_i  = 0;
          axi_s0_tkeep_i  = {TKEEP_L{1'b1}};
          axi_s0_tlast_i  = (i == beats - 1);
          axi_s0_tvalid_i = 1;
          wait (axi_s0_tready_o);
          @(posedge clk);
          axi_s0_tvalid_i = 0;
        end else begin
          axi_s1_tdata_i  = $random;
          axi_s1_tuser_i  = 0;
          axi_s1_tkeep_i  = {TKEEP_L{1'b1}};
          axi_s1_tlast_i  = (i == beats - 1);
          axi_s1_tvalid_i = 1;
          wait (axi_s1_tready_o);
          @(posedge clk);
          axi_s1_tvalid_i = 0;
        end
        @(posedge clk);
      end
    end
  endtask

  initial begin
    // Initialize
    axi_s0_tdata_i  = 0;
    axi_s0_tuser_i  = 0;
    axi_s0_tkeep_i  = 0;
    axi_s0_tlast_i  = 0;
    axi_s0_tvalid_i = 0;

    axi_s1_tdata_i  = 0;
    axi_s1_tuser_i  = 0;
    axi_s1_tkeep_i  = 0;
    axi_s1_tlast_i  = 0;
    axi_s1_tvalid_i = 0;

    // Reset
    repeat (3) @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    // Idle
    repeat (3) @(posedge clk);

    // s0: single-beat
    send_packet(0, 1);

    // s1: single-beat
    send_packet(1, 1);

    // Pause
    repeat (3) @(posedge clk);

    // s0: single-beat (consecutive)
    send_packet(0, 1);
    send_packet(0, 1);

    // Pause
    repeat (3) @(posedge clk);

    // s1: multi-beat (e.g., 3 beats)
    send_packet(1, 3);

    // Pause
    repeat (3) @(posedge clk);

    // Alternate s0/s1, mix single and multi
    send_packet(0, 1);
    send_packet(1, 2);
    send_packet(0, 3);
    send_packet(1, 1);

    repeat (10) @(posedge clk);
    $stop;
  end

endmodule
