`timescale 1ns/1ns

module vga_test_tb(

);

reg clk;
wire [3:0] B;
wire [3:0] G;
wire [3:0] R;
wire HS;
wire VS;

vga_test uut(
    .MAX10_CLK1_50(clk),
    .VGA_B(B),
    .VGA_R(R),
    .VGA_G(G),
    .VGA_HS(HS),
    .VGA_VS(VS)
);

// clock has 20ns period. so we change state every 10ns.
initial begin
    clk = 1'b1;
    forever #10 clk = ~clk;
end

// after 13,852,800ns we should be done
always begin
    #13852800 $stop;
end

endmodule