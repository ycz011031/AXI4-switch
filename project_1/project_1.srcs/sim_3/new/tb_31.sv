`timescale 1ns / 1ps

module axi4_switch_custom_31_tb();

  localparam TDATA_L = 512;
  localparam TUSER_L = 81;
  localparam TKEEP_L = 16;
  localparam MAX_EXPECTED = 128;

  // Clock & Reset
  reg clk = 0;
  reg rst_n = 0;
  always #5 clk = ~clk;  // 100 MHz

  // Cycle counter
  integer cycle = 0;

  // DUT input signals
  reg  [TDATA_L-1:0] axi_s0_tdata_i = 'x, axi_s1_tdata_i = 'x, axi_s2_tdata_i = 'x;
  reg  [TUSER_L-1:0] axi_s0_tuser_i = 'x, axi_s1_tuser_i = 'x, axi_s2_tuser_i = 'x;
  reg                axi_s0_tlast_i = 'x, axi_s1_tlast_i = 'x, axi_s2_tlast_i = 'x;
  reg  [TKEEP_L-1:0] axi_s0_tkeep_i = 'x, axi_s1_tkeep_i = 'x, axi_s2_tkeep_i = 'x;
  reg                axi_s0_tvalid_i = 0, axi_s1_tvalid_i = 0, axi_s2_tvalid_i = 0;
  wire               axi_s0_tready_o, axi_s1_tready_o, axi_s2_tready_o;

  // DUT output signals
  wire [TDATA_L-1:0] axi_m0_tdata_o;
  wire [TUSER_L-1:0] axi_m0_tuser_o;
  wire               axi_m0_tlast_o;
  wire [TKEEP_L-1:0] axi_m0_tkeep_o;
  wire               axi_m0_tvalid_o;
  reg                axi_m0_tready_i = 1;

  // DUT control
  reg [1:0] s_req_supress = 2'b00;

  // DUT instantiation
  axi4_switch_custom_31 #(
    .TDATA_L(TDATA_L), .TUSER_L(TUSER_L), .TKEEP_L(TKEEP_L)
  ) dut (
    .clk(clk), .rst_n(rst_n), .s_req_supress(s_req_supress),

    .axi_s0_tdata_i(axi_s0_tdata_i), .axi_s0_tuser_i(axi_s0_tuser_i),
    .axi_s0_tlast_i(axi_s0_tlast_i), .axi_s0_tkeep_i(axi_s0_tkeep_i),
    .axi_s0_tvalid_i(axi_s0_tvalid_i), .axi_s0_tready_o(axi_s0_tready_o),

    .axi_s1_tdata_i(axi_s1_tdata_i), .axi_s1_tuser_i(axi_s1_tuser_i),
    .axi_s1_tlast_i(axi_s1_tlast_i), .axi_s1_tkeep_i(axi_s1_tkeep_i),
    .axi_s1_tvalid_i(axi_s1_tvalid_i), .axi_s1_tready_o(axi_s1_tready_o),

    .axi_s2_tdata_i(axi_s2_tdata_i), .axi_s2_tuser_i(axi_s2_tuser_i),
    .axi_s2_tlast_i(axi_s2_tlast_i), .axi_s2_tkeep_i(axi_s2_tkeep_i),
    .axi_s2_tvalid_i(axi_s2_tvalid_i), .axi_s2_tready_o(axi_s2_tready_o),

    .axi_m0_tdata_o(axi_m0_tdata_o), .axi_m0_tuser_o(axi_m0_tuser_o),
    .axi_m0_tlast_o(axi_m0_tlast_o), .axi_m0_tkeep_o(axi_m0_tkeep_o),
    .axi_m0_tvalid_o(axi_m0_tvalid_o), .axi_m0_tready_i(axi_m0_tready_i)
  );

  // Per-port expected FIFOs
  reg [TDATA_L-1:0] expected_data_0[0:MAX_EXPECTED-1];
  reg [TUSER_L-1:0] expected_user_0[0:MAX_EXPECTED-1];
  reg               expected_last_0[0:MAX_EXPECTED-1];
  reg [TDATA_L-1:0] expected_data_1[0:MAX_EXPECTED-1];
  reg [TUSER_L-1:0] expected_user_1[0:MAX_EXPECTED-1];
  reg               expected_last_1[0:MAX_EXPECTED-1];
  reg [TDATA_L-1:0] expected_data_2[0:MAX_EXPECTED-1];
  reg [TUSER_L-1:0] expected_user_2[0:MAX_EXPECTED-1];
  reg               expected_last_2[0:MAX_EXPECTED-1];
  integer head_0 = 0, tail_0 = 0;
  integer head_1 = 0, tail_1 = 0;
  integer head_2 = 0, tail_2 = 0;

  task push_expected(input integer port, input [TDATA_L-1:0] d, input [TUSER_L-1:0] u, input bit l);
    case (port)
      0: begin expected_data_0[tail_0] = d; expected_user_0[tail_0] = u; expected_last_0[tail_0] = l; tail_0++; end
      1: begin expected_data_1[tail_1] = d; expected_user_1[tail_1] = u; expected_last_1[tail_1] = l; tail_1++; end
      2: begin expected_data_2[tail_2] = d; expected_user_2[tail_2] = u; expected_last_2[tail_2] = l; tail_2++; end
    endcase
  endtask

   task pop_and_check;
    reg [TDATA_L-1:0] exp_d;
    reg [TUSER_L-1:0] exp_u;
    reg               exp_l;
    integer sel;
    string port_str;
    if (axi_m0_tvalid_o && axi_m0_tready_i) begin
      sel = axi_m0_tdata_o[31:24] == 8'hA0 ? 0 :
            (axi_m0_tdata_o[31:24] == 8'hB0 ? 1 : 2);
      case (sel)
        0: begin exp_d = expected_data_0[head_0]; exp_u = expected_user_0[head_0]; exp_l = expected_last_0[head_0]; head_0++; port_str = "Port 0"; end
        1: begin exp_d = expected_data_1[head_1]; exp_u = expected_user_1[head_1]; exp_l = expected_last_1[head_1]; head_1++; port_str = "Port 1"; end
        2: begin exp_d = expected_data_2[head_2]; exp_u = expected_user_2[head_2]; exp_l = expected_last_2[head_2]; head_2++; port_str = "Port 2"; end
      endcase
      if (axi_m0_tdata_o !== exp_d || axi_m0_tuser_o !== exp_u || axi_m0_tlast_o !== exp_l) begin
        $display("ERROR at cycle %0d on %s:", cycle, port_str);
        $display("  Expected TDATA : %h", exp_d);
        $display("  Received TDATA : %h", axi_m0_tdata_o);
        $fatal("AXI output mismatch.");
      end
    end
  endtask


  integer port2_counter = 0;

  task send_beat(input integer port, input bit last);
    reg [TDATA_L-1:0] data;
    reg [TUSER_L-1:0] user;
    begin

      if (port == 0)
        data = {480'h0, 32'hA0A00000+cycle[7:0]};
      else if (port == 1)
        data = {480'h0, 32'hB0B00000+cycle[7:0]};
      else begin
        data = {480'h0, 32'hC0C00000+cycle[7:0]};
      end

      user = data;

      case (port)
        0: begin
          axi_s0_tdata_i  = data; axi_s0_tuser_i  = user;
          axi_s0_tkeep_i  = {TKEEP_L{1'b1}};
          axi_s0_tlast_i  = last; axi_s0_tvalid_i = 1;
          wait (axi_s0_tready_o); @(posedge clk); axi_s0_tvalid_i = 0;
        end
        1: begin
          axi_s1_tdata_i  = data; axi_s1_tuser_i  = user;
          axi_s1_tkeep_i  = {TKEEP_L{1'b1}};
          axi_s1_tlast_i  = last; axi_s1_tvalid_i = 1;
          wait (axi_s1_tready_o); @(posedge clk); axi_s1_tvalid_i = 0;
        end
        2: begin
          axi_s2_tdata_i  = data; axi_s2_tuser_i  = user;
          axi_s2_tkeep_i  = {TKEEP_L{1'b1}};
          axi_s2_tlast_i  = last; axi_s2_tvalid_i = 1;
          wait (axi_s2_tready_o); @(posedge clk); axi_s2_tvalid_i = 0;
        end
      endcase

      push_expected(port, data, user, last);
    end
  endtask

  initial begin
    axi_s0_tvalid_i = 0; axi_s1_tvalid_i = 0; axi_s2_tvalid_i = 0;
    repeat (10) @(posedge clk);
    rst_n = 1;
  end

  always @(posedge clk) begin
    cycle <= cycle + 1;
    pop_and_check();
  end

  // Port 0 stimulus
  always @(posedge clk) begin
    if (rst_n) begin
      case (cycle)
        20, 40, 60: send_beat(0, 1);
        110: begin send_beat(0,0); send_beat(0,1);end
      endcase
    end
  end

  // Port 1 stimulus
  always @(posedge clk) begin
    if (rst_n) begin
      case (cycle)
        25: begin send_beat(1, 0); send_beat(1, 1); end
        70: send_beat(1, 1);
        //110: begin send_beat(1,0); send_beat(1,1);end
      endcase
    end
  end

  // Port 2 stimulus
  always @(posedge clk) begin
    if (rst_n) begin
      case (cycle)
        30, 50: send_beat(2, 1);
        100: begin send_beat(2, 0); send_beat(2, 1); end
        //110: begin send_beat(2,0); send_beat(2,1);end
        // Add more test vectors here as needed
      endcase
    end
  end

  initial begin
    repeat (200) @(posedge clk);
    if ((head_0 != tail_0) || (head_1 != tail_1) || (head_2 != tail_2))
      $fatal("Some expected outputs were not seen. Remaining - P0: %0d, P1: %0d, P2: %0d", tail_0 - head_0, tail_1 - head_1, tail_2 - head_2);
    else
      $display("PASS: All outputs matched.");
    $finish;
  end

endmodule
