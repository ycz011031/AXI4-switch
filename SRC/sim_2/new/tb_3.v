`timescale 1ns / 1ps

module axi4_switch_custom_tb();

  // Parameters
  localparam TDATA_L = 512;
  localparam TUSER_L = 81;
  localparam TKEEP_L = 16;
  localparam MAX_EXPECTED = 128;

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

  // Expected tracking (manual array replacement for struct queue)
  reg [TDATA_L-1:0] expected_data [0:MAX_EXPECTED-1];
  reg [TUSER_L-1:0] expected_user [0:MAX_EXPECTED-1];
  reg               expected_last [0:MAX_EXPECTED-1];
  integer expected_head = 0;
  integer expected_tail = 0;

  task push_expected(input [TDATA_L-1:0] data, input [TUSER_L-1:0] user, input bit last);
    begin
      expected_data[expected_tail] = data;
      expected_user[expected_tail] = user;
      expected_last[expected_tail] = last;
      expected_tail = expected_tail + 1;
    end
  endtask

  task pop_and_check_output;
    begin
      if (axi_m0_tdata_o !== expected_data[expected_head])
        $fatal("DATA MISMATCH. Got %h expected %h", axi_m0_tdata_o, expected_data[expected_head]);
      if (axi_m0_tuser_o !== expected_user[expected_head])
        $fatal("USER MISMATCH. Got %h expected %h", axi_m0_tuser_o, expected_user[expected_head]);
      if (axi_m0_tlast_o !== expected_last[expected_head])
        $fatal("LAST MISMATCH. Got %b expected %b", axi_m0_tlast_o, expected_last[expected_head]);
      expected_head = expected_head + 1;
    end
  endtask

  task send_packet(input integer port, input integer beats, input [31:0] base_data, input [31:0] base_user);
    integer i;
    begin
      for (i = 0; i < beats; i = i + 1) begin
        reg [TDATA_L-1:0] data = {base_data, i};
        reg [TUSER_L-1:0] user = {base_user, i};
        reg last = (i == beats - 1);
        push_expected(data, user, last);

        if (port == 0) begin
          axi_s0_tdata_i  = data;
          axi_s0_tuser_i  = user;
          axi_s0_tkeep_i  = {TKEEP_L{1'b1}};
          axi_s0_tlast_i  = last;
          axi_s0_tvalid_i = 1;
          wait (axi_s0_tready_o);
          @(posedge clk);
          axi_s0_tvalid_i = 0;
        end else begin
          axi_s1_tdata_i  = data;
          axi_s1_tuser_i  = user;
          axi_s1_tkeep_i  = {TKEEP_L{1'b1}};
          axi_s1_tlast_i  = last;
          axi_s1_tvalid_i = 1;
          wait (axi_s1_tready_o);
          @(posedge clk);
          axi_s1_tvalid_i = 0;
        end
        @(posedge clk);
      end
    end
  endtask

  always @(posedge clk) begin
    if (axi_m0_tvalid_o && axi_m0_tready_i && expected_head != expected_tail) begin
      pop_and_check_output();
    end
  end

  initial begin
    // Reset
    axi_s0_tvalid_i = 0;
    axi_s1_tvalid_i = 0;
    repeat (100) @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    // Idle
    repeat (3) @(posedge clk);

    // s0: single-beat
    send_packet(0, 1, 32'hA0010000, 32'hB0010000);

    // s1: single-beat
    send_packet(1, 1, 32'hA0020000, 32'hB0020000);

    // Pause
    repeat (3) @(posedge clk);

    // s0: consecutive single-beat
    send_packet(0, 1, 32'hA0030000, 32'hB0030000);
    send_packet(0, 1, 32'hA0040000, 32'hB0040000);

    // Pause
    repeat (3) @(posedge clk);

    // s1: multi-beat (3)
    send_packet(1, 3, 32'hA0050000, 32'hB0050000);

    // Pause
    repeat (3) @(posedge clk);

    // Alternating packets
    send_packet(0, 1, 32'hA0060000, 32'hB0060000);
    send_packet(1, 2, 32'hA0070000, 32'hB0070000);
    send_packet(0, 3, 32'hA0080000, 32'hB0080000);
    send_packet(1, 1, 32'hA0090000, 32'hB0090000);

    // Concurrent test: each port wants to send 2
    fork
      send_packet(0, 2, 32'hA0A00000, 32'hB0A00000);
      send_packet(1, 2, 32'hA0B00000, 32'hB0B00000);
    join

    repeat (20) @(posedge clk);
    if (expected_head != expected_tail) $fatal("Expected queue not empty: %0d remaining", expected_tail - expected_head);
    $display("Test passed. All transactions matched expected output.");
    $stop;
  end

endmodule
