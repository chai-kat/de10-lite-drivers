// VGA module for the DE10-Lite board
// outputs red to 800x600 VGA with HSync and VSync

// first 3 are inputs from the framebuffer
module vga_test(
    input MAX10_CLK1_50,
    output VGA_B[3:0],
    output VGA_R[3:0],
    output VGA_G[3:0],
    output VGA_HS,
    output VGA_VS, 
);

// there are 1040 pixels in a line, so we keep track of where we are
reg [10:0] hsync_counter;

// there are 666 lines in the whole frame
reg [9:0] vsync_counter;

initial begin 
	hsync_counter <= 11'b00000000000;
	vsync_counter <= 10'b0000000000;
end

// for this one, HSYNC and VSYNC are both POSITIVE
always @(posedge MAX10_CLK1_50) begin
	// front porch of 56 pixels
	if ((hsync_counter >= 0) or (hsync_counter <= 56)) begin
	
	end
	
	// hsync pulse of 120 pixels
	else if ((hsync_counter >= 57) or (hsync_counter <= 177)) begin
	
	end
	
	// back porch of 64 pixels
	
	//video of 800 pixels
	
	hsync_counter = hsync_counter + 1;
end