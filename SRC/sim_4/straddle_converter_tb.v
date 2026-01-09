`timescale 1ns / 1ps

module straddle_converter_tb;

// Parameters
parameter integer AXI_TUSER_L = 161;
parameter integer BUFFER_SIZE = 8;
parameter CLK_PERIOD = 10; // 10ns = 100MHz

// Clock and Reset
reg ACLK;
reg ARESETN;

// Individual TUSER control signals (user can set these directly)
reg [3:0] is_sop;           // S_AXIS_TUSER[67:64]
reg [3:0] is_eop;           // S_AXIS_TUSER[79:76]
reg [1:0] is_sop0_ptr;      // S_AXIS_TUSER[69:68]
reg [1:0] is_sop1_ptr;      // S_AXIS_TUSER[71:70]
reg [3:0] is_eop0_ptr;      // S_AXIS_TUSER[83:80]
reg [3:0] is_eop1_ptr;      // S_AXIS_TUSER[87:84]
reg discontinue;            // S_AXIS_TUSER[96]

// Byte lane data inputs (will be replicated across the lane)
reg [7:0] byte_lane1;       // Duplicated through lane 00 (bits 255:0)
reg [7:0] byte_lane2;       // Duplicated through lane 10 (bits 511:256)

// Slave AXI Interface signals
wire [AXI_TUSER_L-1:0] S_AXIS_TUSER;
wire [511:0] S_AXIS_TDATA;
wire [15:0] S_AXIS_TKEEP;
reg S_AXIS_TLAST;
reg S_AXIS_TVALID;
wire S_AXIS_TREADY;

// Master AXI Interface signals
wire [AXI_TUSER_L-1:0] M_AXIS_TUSER;
wire [511:0] M_AXIS_TDATA;
wire [15:0] M_AXIS_TKEEP;
wire M_AXIS_TLAST;
wire M_AXIS_TVALID;
reg M_AXIS_TREADY;

// Error output
wire error_invalid_state;

// Combinationally construct S_AXIS_TUSER from individual signals
assign S_AXIS_TUSER[63:0]   = 64'b0;              // [63:0] - unused, set to 0
assign S_AXIS_TUSER[67:64]  = is_sop;             // [67:64] - is_sop
assign S_AXIS_TUSER[69:68]  = is_sop0_ptr;        // [69:68] - is_sop0_ptr
assign S_AXIS_TUSER[71:70]  = is_sop1_ptr;        // [71:70] - is_sop1_ptr
assign S_AXIS_TUSER[75:72]  = 4'b0;               // [75:72] - unused
assign S_AXIS_TUSER[79:76]  = is_eop;             // [79:76] - is_eop
assign S_AXIS_TUSER[83:80]  = is_eop0_ptr;        // [83:80] - is_eop0_ptr
assign S_AXIS_TUSER[87:84]  = is_eop1_ptr;        // [87:84] - is_eop1_ptr
assign S_AXIS_TUSER[95:88]  = 8'b0;               // [95:88] - unused
assign S_AXIS_TUSER[96]     = discontinue;        // [96] - discontinue
assign S_AXIS_TUSER[AXI_TUSER_L-1:97] = 64'b0;    // [160:97] - unused

// Combinationally construct S_AXIS_TDATA by replicating byte lanes
// Lane 00 (bits 255:0) = byte_lane1 replicated 32 times
// Lane 10 (bits 511:256) = byte_lane2 replicated 32 times
assign S_AXIS_TDATA = {
    {32{byte_lane2}},  // Upper 256 bits (lane 10)
    {32{byte_lane1}}   // Lower 256 bits (lane 00)
};

// TKEEP is always all ones
assign S_AXIS_TKEEP = 16'hFFFF;

// Instantiate the DUT (Device Under Test)
axi4_straddle_convertor #(
    .AXI_TUSER_L(AXI_TUSER_L),
    .BUFFER_SIZE(BUFFER_SIZE)
) dut (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    
    .S_AXIS_TUSER(S_AXIS_TUSER),
    .S_AXIS_TDATA(S_AXIS_TDATA),
    .S_AXIS_TKEEP(S_AXIS_TKEEP),
    .S_AXIS_TLAST(S_AXIS_TLAST),
    .S_AXIS_TVALID(S_AXIS_TVALID),
    .S_AXIS_TREADY(S_AXIS_TREADY),
    
    .M_AXIS_TUSER(M_AXIS_TUSER),
    .M_AXIS_TDATA(M_AXIS_TDATA),
    .M_AXIS_TKEEP(M_AXIS_TKEEP),
    .M_AXIS_TLAST(M_AXIS_TLAST),
    .M_AXIS_TVALID(M_AXIS_TVALID),
    .M_AXIS_TREADY(M_AXIS_TREADY),
    
    .error_invalid_state(error_invalid_state)
);

// Clock generation
initial begin
    ACLK = 0;
    forever #(CLK_PERIOD/2) ACLK = ~ACLK;
end

// Helper task to apply a clock cycle
task tick;
    begin
        @(posedge ACLK);
    end
endtask

// Helper task to reset the system
task reset_system;
    begin
        ARESETN = 0;
        S_AXIS_TVALID = 0;
        S_AXIS_TLAST = 0;
        M_AXIS_TREADY = 0;
        
        // Clear control signals
        is_sop = 4'b0000;
        is_eop = 4'b0000;
        is_sop0_ptr = 2'b00;
        is_sop1_ptr = 2'b00;
        is_eop0_ptr = 4'b0000;
        is_eop1_ptr = 4'b0000;
        discontinue = 1'b0;
        
        byte_lane1 = 8'h00;
        byte_lane2 = 8'h00;
        
        repeat(5) tick();
        ARESETN = 1;
        repeat(2) tick();
    end
endtask

// Helper task to send a beat on slave interface
task send_beat(
    input [3:0] sop,
    input [3:0] eop,
    input [1:0] sop0_ptr_val,
    input [1:0] sop1_ptr_val,
    input [3:0] eop0_ptr_val,
    input [3:0] eop1_ptr_val,
    input disc,
    input [7:0] lane1_data,
    input [7:0] lane2_data,
    input tlast
);
    begin
        is_sop <= sop;
        is_eop <= eop;
        is_sop0_ptr <= sop0_ptr_val;
        is_sop1_ptr <= sop1_ptr_val;
        is_eop0_ptr <= eop0_ptr_val;
        is_eop1_ptr <= eop1_ptr_val;
        discontinue <= disc;
        byte_lane1 <= lane1_data;
        byte_lane2 <= lane2_data;
        S_AXIS_TLAST <= tlast;
        S_AXIS_TVALID <= 1;
        
        tick();
        while (!S_AXIS_TREADY) tick();
        
        S_AXIS_TVALID <= 0;
    end
endtask

// Monitor for master interface
always @(posedge ACLK) begin
    if (M_AXIS_TVALID && M_AXIS_TREADY) begin
        $display("[%0t] M_AXIS: TDATA[7:0]=0x%02h TDATA[263:256]=0x%02h TKEEP=0x%04h TLAST=%b", 
                 $time, M_AXIS_TDATA[7:0], M_AXIS_TDATA[263:256], M_AXIS_TKEEP, M_AXIS_TLAST);
    end
end

// Monitor for errors
always @(posedge ACLK) begin
    if (error_invalid_state) begin
        $display("[%0t] ERROR: Invalid state detected!", $time);
    end
end

// Main test sequence (user can modify this)
initial begin
    $display("Starting AXI4 Straddle Converter Testbench");
    
    // Initialize waveform dump
    $dumpfile("straddle_converter_tb.vcd");
    $dumpvars(0, straddle_converter_tb);
    
    // Reset the system
    reset_system();
    
    // Enable master ready
    M_AXIS_TREADY = 1;
    
    // ========================================
    // USER TEST SEQUENCE GOES HERE
    // ========================================
    
    // Example: Send a single TLP starting at lane 00
    $display("\n[%0t] Test 1: Single TLP on lane 00", $time);
    send_beat(
        .sop(4'b0001),           // SOP on lane 0
        .eop(4'b0000),           // No EOP
        .sop0_ptr_val(2'b00),    // SOP0 at byte 0
        .sop1_ptr_val(2'b00),
        .eop0_ptr_val(4'b0000),
        .eop1_ptr_val(4'b0000),
        .disc(1'b0),
        .lane1_data(8'hAA),      // Data 0xAA in lane 00
        .lane2_data(8'h00),
        .tlast(1'b0)
    );
    
    send_beat(
        .sop(4'b0000),
        .eop(4'b0001),           // EOP on lane 0
        .sop0_ptr_val(2'b00),
        .sop1_ptr_val(2'b00),
        .eop0_ptr_val(4'b0111),  // EOP0 at byte 7
        .eop1_ptr_val(4'b0000),
        .disc(1'b0),
        .lane1_data(8'hBB),
        .lane2_data(8'h00),
        .tlast(1'b0)
    );
    
    repeat(10) tick();
    
    // ========================================
    // END OF USER TEST SEQUENCE
    // ========================================
    
    $display("\n[%0t] Testbench Complete", $time);
    $finish;
end

// Timeout watchdog
initial begin
    #100000; // 100us timeout
    $display("\n[%0t] ERROR: Testbench timeout!", $time);
    $finish;
end

endmodule
