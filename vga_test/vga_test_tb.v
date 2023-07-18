module vga_test_tb(

);

reg clk;
reg [3:0] B;
reg [3:0] G;
reg [3:0] R;
reg HS;
reg VS;

uut vga_test(
    .MAX10_CLK1_50(clk),
    .VGA_B(B),
    .VGA_R(R),
    .VGA_G(G),
    .VGA_HS(HS),
    .VGA_VS(VS)
);

initial begin
    clk = 1'b0;
    forever #10 clk = ~clk;
end