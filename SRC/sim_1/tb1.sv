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

  // Global cycle counter
  integer cycle = 0;

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

  reg [TDATA_L-1:0] expected_data [0:MAX_EXPECTED-1];
  reg [TUSER_L-1:0] expected_user [0:MAX_EXPECTED-1];
  reg               expected_last [0:MAX_EXPECTED-1];
  reg finished = '0;
  reg error    = '0;
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
      expected_head = expected_head + 1;
    end
  endtask

  task send_beat(input integer port, input [TDATA_L-1:0] data, input [TUSER_L-1:0] user, input bit last);
    begin
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
        axi_s0_tlast_i  = 'x;
      end else begin
        axi_s1_tdata_i  = data;
        axi_s1_tuser_i  = user;
        axi_s1_tkeep_i  = {TKEEP_L{1'b1}};
        axi_s1_tlast_i  = last;
        axi_s1_tvalid_i = 1;
        wait (axi_s1_tready_o);
        @(posedge clk);
        axi_s1_tvalid_i = 0;
        axi_s1_tlast_i  = 'x;
      end
    end
  endtask

  always @(posedge clk) begin
    cycle <= cycle + 1;
    if (axi_m0_tvalid_o && axi_m0_tready_i && expected_head != expected_tail) begin
      pop_and_check_output();
    end
  end

  initial begin
    axi_s0_tvalid_i = 0;
    axi_s1_tvalid_i = 0;
    repeat (20) @(posedge clk);
    rst_n = 1;
  end

  // Port 0 Process
  always @(posedge clk) begin
    if (!rst_n) disable port0_driver;
    else begin : port0_driver
      case (cycle)
        30: send_beat(0, 32'hA0010001, 32'hB0010001, 1);
        40: send_beat(0, 32'hA0030001, 32'hB0030001, 1);
        50: send_beat(0, 32'hA0040001, 32'hB0040001, 1);
        80: send_beat(0, 32'hA0060001, 32'hB0060001, 1);
        100: begin send_beat(0, 32'hA0080001, 32'hB0080001, 0); send_beat(0, 32'hA0080002, 32'hB0080002, 1); end
        120: begin send_beat(0, 32'hA0A00001, 32'hB0A00001, 0); send_beat(0, 32'hA0A00002, 32'hB0A00002, 1); end
        140: begin send_beat(0, 32'hA0A00002, 32'hA0A00002, 0); send_beat(0, 32'hA0A00002, 32'hA0A00002, 1); end
        150: begin send_beat(0, 32'hA0A00003, 32'hA0A00003, 0); send_beat(0, 32'hA0A00003, 32'hA0A00003, 1); send_beat(0, 32'hA0A00004, 32'hA0A00004, 0); send_beat(0, 32'hA0A00004, 32'hA0A00004, 1); end
        160: send_beat(0, 32'hA0A00005, 32'hA0A00005, 0);
        170: send_beat(0, 32'hA0A00006, 32'hA0A00006, 1);
      endcase
    end
  end

  // Port 1 Process
  always @(posedge clk) begin
    if (!rst_n) disable port1_driver;
    else begin : port1_driver
      case (cycle)
        35: send_beat(1, 32'hA0020001, 32'hB0020001, 1);
        70: begin send_beat(1, 32'hA0050001, 32'hB0050001, 0); send_beat(1, 32'hA0050002, 32'hB0050002, 0); send_beat(1, 32'hA0050003, 32'hB0050003, 1); end
        90: begin send_beat(1, 32'hA0070001, 32'hB0070001, 0); send_beat(1, 32'hA0070002, 32'hB0070002, 1); end
        110: send_beat(1, 32'hA0090001, 32'hB0090001, 1);
        130: begin send_beat(1, 32'hA0B00001, 32'hB0B00001, 0); send_beat(1, 32'hA0B00002, 32'hB0B00002, 1); end
        140: begin send_beat(1, 32'hB0A00002, 32'hB0A00002, 0); send_beat(1, 32'hB0A00002, 32'hB0A00002, 1); end
        150: begin send_beat(1, 32'hB0A00003, 32'hB0A00003, 0); send_beat(1, 32'hB0A00003, 32'hB0A00003, 1);send_beat (1, 32'hB0A00004, 32'hB0A00004, 0); send_beat(1, 32'hB0A00004, 32'hB0A00004, 1);end
        165: send_beat(1, 32'hB0A00005, 32'hB0A00005, 1);
        
      endcase
    end
  end

  initial begin
    repeat (180) @(posedge clk);
    finished <= '1;
    if (expected_head != expected_tail) begin
        error <= '1;
    end else $display("Test passed. All transactions matched expected output.");
    $stop;
  end

endmodule
