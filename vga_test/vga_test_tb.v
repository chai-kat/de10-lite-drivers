`timescale 1ns/100ps

module vga_test_tb(

);

reg clk;
wire [3:0] B;
wire [3:0] G;
wire [3:0] R;
wire HS;
wire VS;
wire [9:0] LEDR;

vga_test #(
    .H_VISIBLE_AREA(800),
    .H_FRONT_PORCH(40),
    .H_SYNC_PULSE(128),
    .H_BACK_PORCH(88),

    .V_VISIBLE_AREA(600),
    .V_FRONT_PORCH(1),
    .V_SYNC_PULSE(4),
    .V_BACK_PORCH(23),

    // 0 for positive HSYNC pulse (i.e starts low goes high)
    // 1 for negative HSYNC pulse (i.e. starts high goes low)
    .HSYNC_POLARITY(1'b0),
    .VSYNC_POLARITY(1'b0)
)

uut(
    .VGA_CLK(clk),
    .VGA_B(B),
    .VGA_R(R),
    .VGA_G(G),
    .VGA_HS(HS),
    .VGA_VS(VS),
    .LEDR(LEDR)
);

// at 50 MHz clock has 20ns period. so we change state every 10ns.
// at 40 MHz clock has 25ns period. so we change state every 12.5ns.
initial begin
    clk = 1'b1;
    // forever #10 clk = ~clk;
    forever #12.5 clk = ~clk;
end

// after 13,852,800ns we should be done for VESA 800x600 @ 72Hz
// after 16,579,200ns we should be done for SVGA 800x600 @ 60Hz
always begin
    // #13852800 $stop;
    #16579200 $stop;
end

endmodule