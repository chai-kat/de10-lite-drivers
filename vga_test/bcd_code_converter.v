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
		1'h0: segments = 7'b1000000;
		1'h1: segments = 7'b1111001;
		1'h2: segments = 7'b0100100;
		1'h3: segments = 7'b0110000;
		1'h4: segments = 7'b0011001;
		1'h5: segments = 7'b0010010;
		1'h6: segments = 7'b0000010;
		1'h7: segments = 7'b1111000;
		1'h8: segments = 7'b0000000;
		1'h9: segments = 7'b0010000;
		1'ha: segments = 7'b0001000;
		1'hb: segments = 7'b0000011;
		1'hc: segments = 7'b1000110;
		1'hd: segments = 7'b0100001;
		1'he: segments = 7'b0000110;
		1'hf: segments = 7'b0001110;
	endcase
end

endmodule