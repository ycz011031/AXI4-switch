module axi4_straddle_convertor #
(
    parameter integer AXI_TUSER_L        = 161,
    parameter integer BUFFER_SIZE        = 1024,
)
(
    // Global Signals
    input wire                                  ACLK,
    input wire                                  ARESETN,

    // Slave AXI Interface
    input wire [AXI_TUSER_L-1:0]               S_AXIS_TUSER,
    input wire [511:0]                         S_AXIS_TDATA,
    input wire [15:0]                          S_AXIS_TKEEP,
    input wire                                 S_AXIS_TLAST,
    input wire                                 S_AXIS_TVALID,
    output wire                                S_AXIS_TREADY,

    // Master AXI Interface
    output wire [AXI_TUSER_L-1:0]              M_AXIS_TUSER,
    output wire [511:0]                        M_AXIS_TDATA,
    output wire [15:0]                         M_AXIS_TKEEP,
    output wire                                M_AXIS_TLAST,
    output wire                                M_AXIS_TVALID,
    input wire                                 M_AXIS_TREADY
);




reg [511:0] data0_reg [0:BUFFER_SIZE-1];
reg [15:0]  keep0_reg [0:BUFFER_SIZE-1];


reg [511:0] data1_reg [0:BUFFER_SIZE-1];
reg [15:0]  keep1_reg [0:BUFFER_SIZE-1];

// Write and read pointers for each data_reg
reg [$clog2(BUFFER_SIZE)-1:0] write_ptr0, read_ptr0;
reg [$clog2(BUFFER_SIZE)-1:0] write_ptr1, read_ptr1;

reg buffer1_full, buffer1_empty;
reg buffer0_full, buffer0_empty;
reg [1:0] tlp_active;
reg [1:0] tlp_active_next;
reg tlp0_complete, tlp1_complete;  // Flags to track if TLP is fully received

// Byte lane tracker: tracks which byte lane each TLP occupies
// [1:0] - byte lanes for TLP0 (bit 0 = lane 00, bit 1 = lane 10)
// [3:2] - byte lanes for TLP1 (bit 2 = lane 00, bit 3 = lane 10)
reg [3:0] byte_lane_tracker;
reg [3:0] byte_lane_tracker_next;

wire [3:0]  is_sop;
wire [3:0]  is_eop;
wire [1:0]  is_sop0_ptr, is_sop1_ptr;
wire [3:0]  is_eop0_ptr, is_eop1_ptr;
wire discontinue;

// Decoding TUSER to find SOP and EOP
// TODO support cq AXI_STREAM_TUSER format
assign is_sop = (AXI_TUSER_L == 161) ? S_AXIS_TUSER[67:64] : 4'b0001;
assign is_eop = (AXI_TUSER_L == 161) ? S_AXIS_TUSER[79:76] : 4'b0001;
assign is_sop0_ptr = (AXI_TUSER_L == 161) ? S_AXIS_TUSER[69:68] : 2'b00;
assign is_sop1_ptr = (AXI_TUSER_L == 161) ? S_AXIS_TUSER[71:70] : 2'b00;
assign is_eop0_ptr = (AXI_TUSER_L == 161) ? S_AXIS_TUSER[83:80] : 2'b00;
assign is_eop1_ptr = (AXI_TUSER_L == 161) ? S_AXIS_TUSER[87:84] : 2'b00;
assign discontinue = (AXI_TUSER_L == 161) ? S_AXIS_TUSER[96] : 1'b0;

assign S_AXIS_TREADY = M_AXIS_TREADY && !buffer0_full && !buffer1_full;

// Output from buffers only when TLP is complete
assign M_AXIS_TVALID = tlp0_complete || tlp1_complete;
assign M_AXIS_TDATA = tlp0_complete ? data0_reg[read_ptr0] : data1_reg[read_ptr1];
assign M_AXIS_TKEEP = tlp0_complete ? keep0_reg[read_ptr0] : keep1_reg[read_ptr1];
assign M_AXIS_TUSER = S_AXIS_TUSER; // This might need more complex logic
assign M_AXIS_TLAST = tlp0_complete ? (read_ptr0 == write_ptr0 - 1) : (read_ptr1 == write_ptr1 - 1);


// Combinational logic for next state of tlp_active and byte_lane_tracker
always @(*) begin
    tlp_active_next = tlp_active;
    byte_lane_tracker_next = byte_lane_tracker;
    
    if (S_AXIS_TVALID && S_AXIS_TREADY) begin
        // Handle SOP (start of packet) - left shift and fill with 1
        if (is_sop[1] && is_sop[0]) begin
            // Both starting: left shift by 2, fill lower 2 bits with 1
            tlp_active_next = {tlp_active[1:0], 2'b11};
            // Left shift byte lane tracker by 4 bits (2 TLPs worth)
            // New TLP0 at is_sop0_ptr, new TLP1 at is_sop1_ptr
            byte_lane_tracker_next = {byte_lane_tracker[1:0], 
                                     (is_sop1_ptr == 2'b10) ? 2'b10 : 2'b01,
                                     (is_sop0_ptr == 2'b10) ? 2'b10 : 2'b01};
        end else if (is_sop[1]) begin
            // Second lane starting: left shift by 2
            tlp_active_next = {tlp_active[1:0], 2'b10};
            byte_lane_tracker_next = {byte_lane_tracker[1:0],
                                     (is_sop1_ptr == 2'b10) ? 2'b10 : 2'b01,
                                     2'b00};
        end else if (is_sop[0]) begin
            // Only first lane starting: left shift by 1, fill with 1
            tlp_active_next = {tlp_active[0], 1'b1};
            // Left shift byte lane tracker by 2 bits (1 TLP worth)
            // Check if lane 10 is free - if so, TLP can use both lanes
            if (is_sop0_ptr == 2'b00) begin
                // Starting at lane 00
                if (byte_lane_tracker[3] == 0) begin
                    // Lane 10 is free, claim both lanes
                    byte_lane_tracker_next = {byte_lane_tracker[1:0], 2'b11};
                end else begin
                    // Lane 10 is occupied, only claim lane 00
                    byte_lane_tracker_next = {byte_lane_tracker[1:0], 2'b01};
                end
            end else begin
                // Starting at lane 10, only claim lane 10
                byte_lane_tracker_next = {byte_lane_tracker[1:0], 2'b10};
            end
        end
        
        // Handle EOP (end of packet) - right shift and zero pad
        if (is_eop[1] && is_eop[0]) begin
            // Both ending: right shift by 2, zero pad upper bits
            tlp_active_next = {2'b00, tlp_active_next[1:0]};
            // Right shift byte lane tracker by 4 bits
            byte_lane_tracker_next = {4'b0000, byte_lane_tracker_next[3:2]};
        end else if (is_eop[0]) begin
            // Only first lane ending: right shift by 1, zero pad
            tlp_active_next = {1'b0, tlp_active_next[1]};
            // Right shift byte lane tracker by 2 bits
            byte_lane_tracker_next = {2'b00, byte_lane_tracker_next[3:2]};
        end
    end
end

// Sequential logic
always @(posedge ACLK) begin
    if (!ARESETN) begin
        write_ptr0 <= 0;
        read_ptr0 <= 0;
        write_ptr1 <= 0;
        read_ptr1 <= 0;
        
        tlp_active <= 2'b00;
        byte_lane_tracker <= 4'b0000;
        buffer0_full <= 0;
        buffer0_empty <= 1;
        buffer1_full <= 0;
        buffer1_empty <= 1;
        tlp0_complete <= 0;
        tlp1_complete <= 0;

    end else begin
        // Update TLP active state and byte lane tracker
        tlp_active <= tlp_active_next;
        byte_lane_tracker <= byte_lane_tracker_next;
        
        // Handle S_AXIS transaction - buffer writes
        if (S_AXIS_TVALID && S_AXIS_TREADY) begin
            // Write to buffer0 if TLP0 is active
            if (tlp_active_next[0]) begin
                // Extract correct byte lanes based on byte_lane_tracker[1:0]
                if (byte_lane_tracker[1:0] == 2'b11) begin
                    // TLP0 uses full 512 bits
                    data0_reg[write_ptr0] <= S_AXIS_TDATA;
                    keep0_reg[write_ptr0] <= S_AXIS_TKEEP;
                end else if (byte_lane_tracker[1:0] == 2'b01) begin
                    // TLP0 uses lane 00 (bits 255:0)
                    data0_reg[write_ptr0] <= {256'b0, S_AXIS_TDATA[255:0]};
                    keep0_reg[write_ptr0] <= {8'b0, S_AXIS_TKEEP[7:0]};
                end else if (byte_lane_tracker[1:0] == 2'b10) begin
                    // TLP0 uses lane 10 (bits 511:256)
                    data0_reg[write_ptr0] <= {S_AXIS_TDATA[511:256], 256'b0};
                    keep0_reg[write_ptr0] <= {S_AXIS_TKEEP[15:8], 8'b0};
                end
                write_ptr0 <= write_ptr0 + 1;
            end
            
            // Check if TLP0 is complete (was active, now going inactive)
            if (tlp_active[0] && !tlp_active_next[0]) begin
                tlp0_complete <= 1;
            end
            
            // Write to buffer1 if TLP1 is active
            if (tlp_active_next[1]) begin
                // Extract correct byte lanes based on byte_lane_tracker[3:2]
                if (byte_lane_tracker[3:2] == 2'b11) begin
                    // TLP1 uses full 512 bits
                    data1_reg[write_ptr1] <= S_AXIS_TDATA;
                    keep1_reg[write_ptr1] <= S_AXIS_TKEEP;
                end else if (byte_lane_tracker[3:2] == 2'b01) begin
                    // TLP1 uses lane 00 (bits 255:0)
                    data1_reg[write_ptr1] <= {256'b0, S_AXIS_TDATA[255:0]};
                    keep1_reg[write_ptr1] <= {8'b0, S_AXIS_TKEEP[7:0]};
                end else if (byte_lane_tracker[3:2] == 2'b10) begin
                    // TLP1 uses lane 10 (bits 511:256)
                    data1_reg[write_ptr1] <= {S_AXIS_TDATA[511:256], 256'b0};
                    keep1_reg[write_ptr1] <= {S_AXIS_TKEEP[15:8], 8'b0};
                end
                write_ptr1 <= write_ptr1 + 1;
            end
            
            // Check if TLP1 is complete (was active, now going inactive)
            if (tlp_active[1] && !tlp_active_next[1]) begin
                tlp1_complete <= 1;
            end
        end

        // Handle M_AXIS transaction (reading from buffer)
        if (M_AXIS_TVALID && M_AXIS_TREADY) begin
            if (tlp0_complete && !buffer0_empty) begin
                read_ptr0 <= read_ptr0 + 1;
                // Check if we've read all of TLP0
                if (read_ptr0 + 1 == write_ptr0) begin
                    tlp0_complete <= 0;
                end
            end else if (tlp1_complete && !buffer1_empty) begin
                read_ptr1 <= read_ptr1 + 1;
                // Check if we've read all of TLP1
                if (read_ptr1 + 1 == write_ptr1) begin
                    tlp1_complete <= 0;
                end
            end
        end

        // Update buffer status
        buffer0_empty <= (write_ptr0 == read_ptr0);
        buffer0_full <= (write_ptr0 + 1 == read_ptr0) || ((write_ptr0 == BUFFER_SIZE - 1) && (read_ptr0 == 0));
        buffer1_empty <= (write_ptr1 == read_ptr1);
        buffer1_full <= (write_ptr1 + 1 == read_ptr1) || ((write_ptr1 == BUFFER_SIZE - 1) && (read_ptr1 == 0));
    end
end
endmodule