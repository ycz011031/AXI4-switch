module axi4_straddle_convertor #
(
    parameter integer AXI_TUSER_L        = 161,
    parameter integer BUFFER_SIZE        = 1024
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
    input wire                                 M_AXIS_TREADY,
    
    // Error output
    output reg [1:0]                                error_invalid_state
);




reg [511:0] data0_reg [0:BUFFER_SIZE-1];
reg [15:0]  keep0_reg [0:BUFFER_SIZE-1];

reg [511:0] data1_reg [0:BUFFER_SIZE-1];
reg [15:0]  keep1_reg [0:BUFFER_SIZE-1];

// Write and read pointers for each data_reg
reg [$clog2(BUFFER_SIZE)-1:0] write_ptr0, read_ptr0;
reg [$clog2(BUFFER_SIZE)-1:0] write_ptr1, read_ptr1;

reg illegal_sop_encountered;
reg illegal_eop_encountered;

reg buffer1_full, buffer1_empty;
reg buffer0_full, buffer0_empty;
reg [1:0] tlp_active;
reg [1:0] tlp_active_next;
reg [1:0] tlp_active_current;

reg old_tlp;
reg old_tlp_current;

// EOP bit vectors to track TLP boundaries in each buffer
reg [BUFFER_SIZE-1:0] buffer0_eop;
reg [BUFFER_SIZE-1:0] buffer1_eop;
reg reading_from_buffer0;  // Tracks which buffer we're currently reading from

// Byte lane tracker: tracks which byte lane each TLP occupies
// [1:0] - byte lanes for TLP0 (bit 0 = lane 00, bit 1 = lane 10)
// [3:2] - byte lanes for TLP1 (bit 2 = lane 00, bit 3 = lane 10)
reg [3:0] byte_lane_tracker;
reg [3:0] byte_lane_tracker_next;
reg [3:0] byte_lane_tracker_current;

// Delayed EOP signals for one-cycle delay in processing
reg [3:0] is_eop_delayed;

// Masked TKEEP signals for EOP handling
reg [15:0] keep0_masked;
reg [15:0] keep1_masked;
reg [15:0] mask0, mask1;

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

assign S_AXIS_TREADY = !buffer0_full && !buffer1_full;

// Output from buffers - alternate based on EOP markers
wire buffer0_has_data = (write_ptr0 != read_ptr0);
wire buffer1_has_data = (write_ptr1 != read_ptr1);

// Use reading_from_buffer0 as tiebreaker when both buffers have data
wire actual_read_from_buffer0 = buffer0_has_data && (!buffer1_has_data || reading_from_buffer0);

assign M_AXIS_TVALID = buffer0_has_data || buffer1_has_data;
assign M_AXIS_TDATA = actual_read_from_buffer0 ? data0_reg[read_ptr0] : data1_reg[read_ptr1];
assign M_AXIS_TKEEP = actual_read_from_buffer0 ? keep0_reg[read_ptr0] : keep1_reg[read_ptr1];
assign M_AXIS_TUSER = S_AXIS_TUSER; // This might need more complex logic
assign M_AXIS_TLAST = actual_read_from_buffer0 ? buffer0_eop[read_ptr0] : buffer1_eop[read_ptr1];


// Combinational logic for TKEEP masking based on EOP
always @(*) begin
    // Default: pass through TKEEP unchanged
    keep0_masked = S_AXIS_TKEEP;
    keep1_masked = S_AXIS_TKEEP;
    mask0 = S_AXIS_TKEEP & ((16'h1 << (is_eop0_ptr + 1)) - 1);
    mask1 = S_AXIS_TKEEP & ((16'h1 << (is_eop1_ptr + 1)) - 1);
    
    
    if (S_AXIS_TVALID && S_AXIS_TREADY) begin
        // Apply EOP mask for TLP0 if it's ending
        if (tlp_active_current[0] && !tlp_active_next[0]) begin
            // when both TLP is ending, apply mask0 when TLP0 is old TLP
            keep0_masked = (is_eop[0]&&(!old_tlp_current)) ? mask0 : mask1;
        end
        
        // Apply EOP mask for TLP1 if it's ending
        if (tlp_active_current[1] && !tlp_active_next[1]) begin
            // when both TLP is ending, apply mask1 when TLP1 is old TLP 
            keep1_masked = (is_eop[1]&&old_tlp_current) ? mask1 : mask0;
        end
    end
end

// Combinational logic for next state of tlp_active and byte_lane_tracker
always @(*) begin
    tlp_active_next            = tlp_active;
    tlp_active_current         = tlp_active;
    byte_lane_tracker_current  = byte_lane_tracker;
    byte_lane_tracker_next     = byte_lane_tracker;
    illegal_sop_encountered    = 1'b0;
    illegal_eop_encountered    = 1'b0;
    
    if (S_AXIS_TVALID && S_AXIS_TREADY) begin
        // Handle SOP (start of packet) - left shift and fill with 1
        casez ({is_sop[1:0],tlp_active})
            4'b11??:begin
                tlp_active_current        = 2'b11;
                byte_lane_tracker_current = 4'b1001;
                old_tlp_current           = 1'b0;
            end
            4'b0100:begin
                tlp_active_current        = 2'b01; // TLP0 starting
                byte_lane_tracker_current = (is_sop0_ptr == 2'b00) ? 4'b0011 : 4'b0010;
                old_tlp_current           = 1'b0;
            end
            4'b0101:begin
                tlp_active_current        = 2'b11; // TLP1 starting
                byte_lane_tracker_current = (is_sop0_ptr == 2'b00) ? 4'b0110 : 4'b1001;
                old_tlp_current           = 1'b0;
            end
            4'b0110:begin
                tlp_active_current        = 2'b11; // TLP0 starting
                byte_lane_tracker_current = (is_sop0_ptr == 2'b00) ? 4'b1001 : 4'b0110;
                old_tlp_current           = 1'b1;
            end
            4'b00??:begin
                tlp_active_current        = tlp_active;
                byte_lane_tracker_current = byte_lane_tracker;
                old_tlp_current           = old_tlp;
            end
            default:begin
                tlp_active_current        = tlp_active;
                byte_lane_tracker_current = byte_lane_tracker;
                old_tlp_current           = old_tlp;
                illegal_sop_encountered   = 1'b1;
            end
        endcase
        casez ({is_eop[1:0],tlp_active_current})
            4'b1111:begin
                tlp_active_next           = 2'b00;
                byte_lane_tracker_next    = 4'b0000;
            end
            4'b0111:begin
                tlp_active_next           = (!old_tlp_current)? 2'b10 : 2'b01; // TLP0 ending
                byte_lane_tracker_next    = (!old_tlp_current)? 4'b1100 : 4'b0011;
            end
            4'b0101:begin
                tlp_active_next           = 2'b00; // TLP0 ending
                byte_lane_tracker_next    = 4'b0000; //all bytelane released
            end
            4'b0110:begin
                tlp_active_next           = 2'b00; // TLP1 ending
                byte_lane_tracker_next    = 4'b0000;
            end
            4'b00??:begin
                tlp_active_next           = tlp_active_current;
                byte_lane_tracker_next    = byte_lane_tracker_current;
            end
            default:begin
                tlp_active_next           = tlp_active_current;
                byte_lane_tracker_next    = byte_lane_tracker_current;
                illegal_eop_encountered   = 1'b1;
            end
        endcase 
    end
end

// Sequential logic
always @(posedge ACLK) begin
    if (!ARESETN) begin
        write_ptr0 <= 0;
        read_ptr0  <= 0;
        write_ptr1 <= 0;
        read_ptr1  <= 0;
        
        tlp_active        <= 2'b00;
        byte_lane_tracker <= 4'b0000;
        is_eop_delayed    <= 4'b0000;
        buffer0_full      <= 0;
        buffer0_empty     <= 1;
        buffer1_full      <= 0;
        buffer1_empty     <= 1;
        old_tlp           <= 0;
        
        buffer0_eop <= {BUFFER_SIZE{1'b0}};
        buffer1_eop <= {BUFFER_SIZE{1'b0}};
       
        reading_from_buffer0 <= 1;  // Start with buffer0 
        error_invalid_state  <= 2'b00;

    end else begin
        is_eop_delayed <= (S_AXIS_TVALID)? is_eop : 4'b1111;
        old_tlp        <= old_tlp_current;
        
        // Update TLP active state and byte lane tracker
        tlp_active        <= S_AXIS_TREADY? tlp_active_next : tlp_active_current;
        byte_lane_tracker <= S_AXIS_TREADY? byte_lane_tracker_next : byte_lane_tracker_current;
        

        if (S_AXIS_TVALID && S_AXIS_TREADY) begin
            // Error: is_sop[1] should not be high when any TLP is already active
            error_invalid_state <= error_invalid_state |{illegal_sop_encountered, illegal_eop_encountered};
        end
        
        // Handle S_AXIS transaction - buffer writes
        if (S_AXIS_TVALID && S_AXIS_TREADY) begin
            // Write to buffer0 if TLP0 is active
            if (tlp_active_current[0]) begin
                // Extract correct byte lanes based on byte_lane_tracker[1:0]
                if (byte_lane_tracker_current[1:0] == 2'b11) begin
                    // TLP0 uses full 512 bits
                    data0_reg[write_ptr0] <= S_AXIS_TDATA;
                    keep0_reg[write_ptr0] <= keep0_masked;
                end else if (byte_lane_tracker_current[1:0] == 2'b01) begin
                    // TLP0 uses lane 00 (bits 255:0)
                    data0_reg[write_ptr0] <= {256'b0, S_AXIS_TDATA[255:0]};
                    keep0_reg[write_ptr0] <= {8'b0, keep0_masked[7:0]};
                end else if (byte_lane_tracker_current[1:0] == 2'b10) begin
                    // TLP0 uses lane 10 (bits 511:256)
                    data0_reg[write_ptr0] <= {S_AXIS_TDATA[511:256], 256'b0};
                    keep0_reg[write_ptr0] <= {keep0_masked[15:8], 8'b0};
                end
                
                // Mark EOP bit if TLP0 is ending
                buffer0_eop[write_ptr0] <= (tlp_active_current[0] && !tlp_active_next[0]);
                write_ptr0 <= write_ptr0 + 1;
            end
            
            // Write to buffer1 if TLP1 is active
            if (tlp_active_current[1]) begin
                // Extract correct byte lanes based on byte_lane_tracker[3:2]
                if (byte_lane_tracker_current[3:2] == 2'b11) begin
                    // TLP1 uses full 512 bits
                    data1_reg[write_ptr1] <= S_AXIS_TDATA;
                    keep1_reg[write_ptr1] <= keep1_masked;
                end else if (byte_lane_tracker_current[3:2] == 2'b01) begin
                    // TLP1 uses lane 00 (bits 255:0)
                    data1_reg[write_ptr1] <= {256'b0, S_AXIS_TDATA[255:0]};
                    keep1_reg[write_ptr1] <= {8'b0, keep1_masked[7:0]};
                end else if (byte_lane_tracker_current[3:2] == 2'b10) begin
                    // TLP1 uses lane 10 (bits 511:256)
                    data1_reg[write_ptr1] <= {S_AXIS_TDATA[511:256], 256'b0};
                    keep1_reg[write_ptr1] <= {keep1_masked[15:8], 8'b0};
                end
                
                // Mark EOP bit if TLP1 is ending
                buffer1_eop[write_ptr1] <= (tlp_active_current[1] && !tlp_active_next[1]);
                write_ptr1 <= write_ptr1 + 1;
            end
        end

        // Handle M_AXIS transaction (reading from buffer) - switch on EOP
        if (M_AXIS_TVALID && M_AXIS_TREADY) begin
            if (actual_read_from_buffer0) begin
                read_ptr0 <= read_ptr0 + 1;
                // Update reading_from_buffer0 only at EOP and when both buffers have data
                if (buffer0_eop[read_ptr0] && buffer1_has_data) begin
                    reading_from_buffer0 <= 0;
                end
            end else begin
                read_ptr1 <= read_ptr1 + 1;
                // Update reading_from_buffer0 only at EOP and when both buffers have data
                if (buffer1_eop[read_ptr1] && buffer0_has_data) begin
                    reading_from_buffer0 <= 1;
                end
            end
        end

        // Update buffer status
        buffer0_empty <= (write_ptr0 == read_ptr0);
        buffer0_full  <= (write_ptr0 + 1 == read_ptr0) || ((write_ptr0 == BUFFER_SIZE - 1) && (read_ptr0 == 0));
        buffer1_empty <= (write_ptr1 == read_ptr1);
        buffer1_full  <= (write_ptr1 + 1 == read_ptr1) || ((write_ptr1 == BUFFER_SIZE - 1) && (read_ptr1 == 0));
    end
end
endmodule