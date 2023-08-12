module bcd_code_converter(
	input [3:0] bcd_digit,
	output reg [6:0] segments
);

// segments is 0:6 above, 
// so we can make a 7 bit number which represents segments abcdefg (clockwise)
// look at image here https://media.geeksforgeeks.org/wp-content/uploads/20200413202916/Untitled-Diagram-237.png 
// is the same as in the DE10-Lite Guide

always @(bcd_digit) begin
	case(bcd_digit)
		0 : segments = 7'b1000000;
		1 : segments = 7'b1111001;
		2 : segments = 7'b0100100;
		3 : segments = 7'b0110000;
		4 : segments = 7'b0011001;
		5 : segments = 7'b0010010;
		6 : segments = 7'b0000010;
		7 : segments = 7'b1111000;
		8 : segments = 7'b0000000;
		9 : segments = 7'b0010000;
		default: segments = 7'b0000110;
	endcase
end

endmodule