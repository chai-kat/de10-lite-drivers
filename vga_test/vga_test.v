`timescale 1ns/100ps

// VGA module for the DE10-Lite board
// outputs red to 800x600 VGA with HSync and VSync
// for this one, HSYNC and VSYNC are both POSITIVE

// first 3 are inputs from the framebuffer
module vga_test # (
    parameter H_VISIBLE_AREA = 800,
    parameter H_FRONT_PORCH = 56,
    parameter H_SYNC_PULSE = 120,
    parameter H_BACK_PORCH = 64,
    
    // calculated parameters
    parameter WHOLE_LINE = H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH,
    parameter CLOG2_WHOLE_LINE = $clog2(WHOLE_LINE),

    parameter V_VISIBLE_AREA = 600,
    parameter V_FRONT_PORCH = 37,
    parameter V_SYNC_PULSE = 6,
    parameter V_BACK_PORCH = 23,
    
    // calculated parameters
    parameter WHOLE_FRAME = V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH,
    parameter CLOG2_WHOLE_FRAME = $clog2(WHOLE_FRAME),

    // 1 for positive HSYNC pulse (i.e starts low goes high)
    // 0 for negative HSYNC pulse (i.e. starts high goes low)
    parameter HSYNC_POLARITY = 1'b0,
    parameter VSYNC_POLARITY = 1'b0
)
(
    input VGA_CLK,
    output reg [3:0] VGA_B,
    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg VGA_HS,
    output reg VGA_VS,
    output [9:0] LEDR 
);

// there are 1040 pixels in a line, so we keep track of where we are
reg [CLOG2_WHOLE_LINE - 1 : 0] hsync_counter;

// there are 666 lines in the whole frame
reg [CLOG2_WHOLE_FRAME - 1 : 0] vsync_counter;

initial begin 
	hsync_counter = {CLOG2_WHOLE_LINE{1'b0}};
	vsync_counter = {CLOG2_WHOLE_FRAME{1'b0}};

    VGA_R = 4'b0000;
    VGA_G = 4'b0000;
    VGA_B = 4'b0000;

    VGA_VS = ~VSYNC_POLARITY;
    VGA_HS = ~HSYNC_POLARITY;
end

assign LEDR[9:0] = vsync_counter[9:0];

always @(negedge VGA_CLK) begin
    // hsync counter (pixel count) can go up to 1039, and then needs to reset to 0
    if (hsync_counter < WHOLE_LINE) begin
        hsync_counter = hsync_counter + 1;
    end
    else begin
        hsync_counter = 0;
    end

end

// TODO: the <= is combinatorial, right? 
// TODO: consider if it will infer a latch. If yes, change to '='
always @(posedge VGA_CLK) begin

    // vsync front porch of e.g 1 lines, parameter given as 1, so we do < V_FRONT_PORCH, not <=
    if ((vsync_counter >= 0) && (vsync_counter < V_FRONT_PORCH)) begin
        VGA_VS = ~VSYNC_POLARITY; // if polarity of vsync is positive then this is 1'b0. else 1'b1.
        VGA_R = 4'b0000;
        VGA_G = 4'b0000;
        VGA_B = 4'b0000;

        if ((hsync_counter >= 0) && (hsync_counter < H_FRONT_PORCH)) begin
            VGA_HS = ~HSYNC_POLARITY; // if polarity of hsync is positive then this is 1'b0. else 1'b1.
        end
        // hsync pulse
        else if ((hsync_counter >= H_FRONT_PORCH) && (hsync_counter < H_FRONT_PORCH + H_SYNC_PULSE)) begin
            VGA_HS = HSYNC_POLARITY; // if polarity of hsync is positive then this is 1'b1. else 1'b0.
        end
        // back porch
        else if ((hsync_counter >= H_FRONT_PORCH + H_SYNC_PULSE) && (hsync_counter < H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH)) begin
            VGA_HS = ~HSYNC_POLARITY; // if polarity of hsync is positive then this is 1'b0. else 1'b1.
        end
        // hsync_counter changes on the positive edge, so we need to change at WHOLE_LINE not WHOLE_LINE -1
        else if (hsync_counter == WHOLE_LINE) begin

            // need to do the switching here or it happens too late
            if (vsync_counter == V_FRONT_PORCH - 1) begin
                VGA_VS = VSYNC_POLARITY;
            end
            else begin
                VGA_VS = ~VSYNC_POLARITY;
            end

            hsync_counter = 0;
            vsync_counter = vsync_counter + 1;
        end
        else begin 
            VGA_HS = ~HSYNC_POLARITY;
        end
    end

    // vsync pulse of 4 lines
    else if ((vsync_counter >= V_FRONT_PORCH) && (vsync_counter < V_FRONT_PORCH + V_SYNC_PULSE)) begin
        VGA_VS = VSYNC_POLARITY;
        VGA_R = 4'b0000;
        VGA_G = 4'b0000;
        VGA_B = 4'b0000;

        if ((hsync_counter >= 0) && (hsync_counter < H_FRONT_PORCH)) begin
            VGA_HS = ~HSYNC_POLARITY; // if polarity of hsync is positive then this is 1'b0. else 1'b1.
        end
        // hsync pulse
        else if ((hsync_counter >= H_FRONT_PORCH) && (hsync_counter < H_FRONT_PORCH + H_SYNC_PULSE)) begin
            VGA_HS = HSYNC_POLARITY; // if polarity of hsync is positive then this is 1'b1. else 1'b0.
        end
        // back porch
        else if ((hsync_counter >= H_FRONT_PORCH + H_SYNC_PULSE) && (hsync_counter <= H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH)) begin
            VGA_HS = ~HSYNC_POLARITY; // if polarity of hsync is positive then this is 1'b0. else 1'b1.
        end
        // hsync_counter changes on the positive edge, so we need to change at WHOLE_LINE not WHOLE_LINE -1
        else if (hsync_counter == WHOLE_LINE) begin
            // need to do the switching here or it happens too late
            if (vsync_counter == V_FRONT_PORCH + V_SYNC_PULSE - 1) begin
                VGA_VS = ~VSYNC_POLARITY;
            end
            else begin
                VGA_VS = VSYNC_POLARITY;
            end

            hsync_counter = 0;
            vsync_counter = vsync_counter + 1;
        end
        else begin 
            VGA_HS = ~HSYNC_POLARITY;
        end
    end

    // vsync back porch of 23 lines
    else if ((vsync_counter >= V_FRONT_PORCH + V_SYNC_PULSE) && (vsync_counter < V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH)) begin
        VGA_VS = ~VSYNC_POLARITY; // if VSP is positive then this is 1'b0. else 1'b1. (bring vsync down if positive pulse)
        VGA_R = 4'b0000;
        VGA_G = 4'b0000;
        VGA_B = 4'b0000;

        if ((hsync_counter >= 0) && (hsync_counter < H_FRONT_PORCH)) begin
            VGA_HS = ~HSYNC_POLARITY; // if polarity of hsync is positive then this is 1'b0. else 1'b1.
        end
        // hsync pulse
        else if ((hsync_counter >= H_FRONT_PORCH) && (hsync_counter < H_FRONT_PORCH + H_SYNC_PULSE)) begin
            VGA_HS = HSYNC_POLARITY; // if polarity of hsync is positive then this is 1'b1. else 1'b0.
        end
        // back porch
        else if ((hsync_counter >= H_FRONT_PORCH + H_SYNC_PULSE) && (hsync_counter < H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH)) begin
            VGA_HS = ~HSYNC_POLARITY; // if polarity of hsync is positive then this is 1'b0. else 1'b1.
        end
        // hsync_counter changes on the positive edge, so we need to change at WHOLE_LINE not WHOLE_LINE -1
        else if (hsync_counter == WHOLE_LINE) begin
            hsync_counter = 0;
            vsync_counter = vsync_counter + 1;
        end
        else begin 
            VGA_HS = ~HSYNC_POLARITY;
        end
    end

    // reset hsync_counter and vsync_counter to 0 when we reach the end of the frame
    // TODO: double check that this doesn't cause latching
    else if (vsync_counter == WHOLE_FRAME - 1) begin
        hsync_counter = 0;
        vsync_counter = 0;
    end

    // display portion of frame
    else begin
        // front porch of 56 pixels
        if ((hsync_counter >= 0) && (hsync_counter < H_FRONT_PORCH)) begin
            VGA_HS = ~HSYNC_POLARITY; // if polarity of hsync is positive then this is 1'b0. else 1'b1.
            VGA_R = 4'b0000;
            VGA_G = 4'b0000;
            VGA_B = 4'b0000;
        end
        // hsync pulse of 120 pixels
        else if ((hsync_counter >= H_FRONT_PORCH) && (hsync_counter < H_FRONT_PORCH + H_SYNC_PULSE)) begin
            VGA_HS = HSYNC_POLARITY; // if polarity of hsync is positive then this is 1'b1. else 1'b0.
            VGA_R = 4'b0000;
            VGA_G = 4'b0000;
            VGA_B = 4'b0000;
        end
        // back porch of 64 pixels
        else if ((hsync_counter >= H_FRONT_PORCH + H_SYNC_PULSE) && (hsync_counter <= H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH)) begin
            VGA_HS = ~HSYNC_POLARITY; // if polarity of hsync is positive then this is 1'b0. else 1'b1.
            VGA_R = 4'b0000;
            VGA_G = 4'b0000;
            VGA_B = 4'b0000;
        end
        // hsync_counter changes on the positive edge, so we need to change at WHOLE_LINE not WHOLE_LINE -1
        else if (hsync_counter == WHOLE_LINE) begin
            hsync_counter = 0;
            vsync_counter = vsync_counter + 1;
        end

        //video of however many pixels
        else begin 
            VGA_HS = ~HSYNC_POLARITY;
            VGA_R = 4'b1111;
            VGA_G = 4'b0000;
            VGA_B = 4'b0000;
        end
    end
end

endmodule

// TODO: make this better by having the hline be its own module. 
// then have it feed out a "data ready" on the negative edge of the prev clock to when we want it
// and on the posedge expect the data to be ready for display on VGA and set the RGB appropriately. 
// i.e. the VRAM/frame buffer can feed 1 pixel data when data_ready AND clk are asserted.