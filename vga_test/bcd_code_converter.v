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
		4'h0: segments = 7'b1000000;
		4'h1: segments = 7'b1111001;
		4'h2: segments = 7'b0100100;
		4'h3: segments = 7'b0110000;
		4'h4: segments = 7'b0011001;
		4'h5: segments = 7'b0010010;
		4'h6: segments = 7'b0000010;
		4'h7: segments = 7'b1111000;
		4'h8: segments = 7'b0000000;
		4'h9: segments = 7'b0010000;
		4'ha: segments = 7'b0001000;
		4'hb: segments = 7'b0000011;
		4'hc: segments = 7'b1000110;
		4'hd: segments = 7'b0100001;
		4'he: segments = 7'b0000110;
		4'hf: segments = 7'b0001110;
		default: segments = 7'b1111111; // without default, latch inferred?
	endcase
end

endmodule