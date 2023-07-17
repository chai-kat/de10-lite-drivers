// VGA module for the DE10-Lite board
// takes RGB input from and outputs to VGA with HSync and VSync

// first 3 are inputs from the framebuffer
module vga_test(
    input [3:0] R,
    input [3:0] G,
    input [3:0] B,
    input MAX10_CLK1_50,
    output VGA_B[3:0],
    output VGA_R[3:0],
    output VGA_G[3:0],
    output VGA_HS,
    output VGA_VS, 
);