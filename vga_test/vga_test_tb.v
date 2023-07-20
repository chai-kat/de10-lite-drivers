`timescale 1ps/1ps

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

initial begin
    clk = 1'b0;
end

always begin
   #10 clk = ~clk;
end

endmodule