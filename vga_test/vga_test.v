`timescale 1ns/1ns

// VGA module for the DE10-Lite board
// outputs red to 800x600 VGA with HSync and VSync
// for this one, HSYNC and VSYNC are both POSITIVE

// first 3 are inputs from the framebuffer
module vga_test(
    input MAX10_CLK1_50,
    output reg [3:0] VGA_B,
    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg VGA_HS,
    output reg VGA_VS 
);

// there are 1040 pixels in a line, so we keep track of where we are
reg [10:0] hsync_counter;

// there are 666 lines in the whole frame
reg [9:0] vsync_counter;

initial begin 
	hsync_counter <= 11'b00000000000;
	vsync_counter <= 10'b0000000000;

    VGA_R = 4'b0000;
    VGA_G = 4'b0000;
    VGA_B = 4'b0000;

    VGA_VS = 1'b0;
    VGA_HS = 1'b0;
end

always @(negedge MAX10_CLK1_50) begin
    // hsync counter (pixel count) can go up to 1039, and then needs to reset to 0
    if (hsync_counter < 1039) begin
        hsync_counter = hsync_counter + 1;
    end
    else begin
        hsync_counter = 0;
    end

end

// TODO: the <= is combinatorial, right? 
// TODO: consider if it will infer a latch. If yes, change to '='
always @(posedge MAX10_CLK1_50) begin

    // vsync front porch of 37 lines
    if ((vsync_counter >= 0) && (vsync_counter <= 36)) begin
        VGA_VS = 1'b0;
        VGA_R = 4'b0000;
        VGA_G = 4'b0000;
        VGA_B = 4'b0000;

        // hsync front porch of 56 pixels
        if ((hsync_counter >= 0) && (hsync_counter <= 55)) begin
            VGA_HS = 1'b0;
        end
        // hsync pulse of 120 pixels
        else if ((hsync_counter >= 56) && (hsync_counter <= 175)) begin
            VGA_HS = 1'b1;
        end
        // hsync back porch of 64 pixels
        else if ((hsync_counter >= 176) && (hsync_counter <= 239)) begin
            VGA_HS = 1'b0;
        end
        else if (hsync_counter == 1039) begin
            vsync_counter = vsync_counter + 1;
        end
    end

    // vsync pulse of 6 lines
    else if ((vsync_counter >= 37) && (vsync_counter <= 42)) begin
        VGA_VS = 1'b1;
        VGA_R = 4'b0000;
        VGA_G = 4'b0000;
        VGA_B = 4'b0000;

        // hsync front porch of 56 pixels
        if ((hsync_counter >= 0) && (hsync_counter <= 55)) begin
            VGA_HS = 1'b0;
        end
        // hsync pulse of 120 pixels
        else if ((hsync_counter >= 56) && (hsync_counter <= 175)) begin
            VGA_HS = 1'b1;
        end
        // hsync back porch of 64 pixels
        else if ((hsync_counter >= 176) && (hsync_counter <= 239)) begin
            VGA_HS = 1'b0;
        end
        else if (hsync_counter == 1039) begin
            vsync_counter = vsync_counter + 1;
        end
    end

    // vsync back porch of 23 lines
    else if ((vsync_counter >= 43) && (vsync_counter <= 65)) begin
        VGA_VS = 1'b0;
        VGA_R = 4'b0000;
        VGA_G = 4'b0000;
        VGA_B = 4'b0000;

        // hsync front porch of 56 pixels
        if ((hsync_counter >= 0) && (hsync_counter <= 55)) begin
            VGA_HS = 1'b0;
        end
        // hsync pulse of 120 pixels
        else if ((hsync_counter >= 56) && (hsync_counter <= 175)) begin
            VGA_HS = 1'b1;
        end
        // hsync back porch of 64 pixels
        else if ((hsync_counter >= 176) && (hsync_counter <= 239)) begin
            VGA_HS = 1'b0;
        end
        else if (hsync_counter == 1039) begin
            vsync_counter = vsync_counter + 1;
        end
    end

    // reset vsync to 0
    else if (vsync_counter == 665) begin
        vsync_counter = 0;
    end

    // display portion of frame
    else begin
        // front porch of 56 pixels
        if ((hsync_counter >= 0) && (hsync_counter <= 55)) begin
            VGA_HS = 1'b0;
            VGA_R = 4'b0000;
            VGA_G = 4'b0000;
            VGA_B = 4'b0000;
        end
        // hsync pulse of 120 pixels
        else if ((hsync_counter >= 56) && (hsync_counter <= 175)) begin
            VGA_HS = 1'b1;
            VGA_R = 4'b0000;
            VGA_G = 4'b0000;
            VGA_B = 4'b0000;
        end
        // back porch of 64 pixels
        else if ((hsync_counter >= 176) && (hsync_counter <= 239)) begin
            VGA_HS = 1'b0;
            VGA_R = 4'b0000;
            VGA_G = 4'b0000;
            VGA_B = 4'b0000;
        end
        else if (hsync_counter == 1039) begin
            
            vsync_counter = vsync_counter + 1;
        end

        //video of 800 pixels
        else begin 
            VGA_HS = 1'b0;
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