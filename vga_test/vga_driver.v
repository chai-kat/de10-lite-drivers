`timescale 1ns/100ps

// VGA module for the DE10-Lite board
// outputs red to 800x600 VGA with HSync and VSync
// for this one, HSYNC and VSYNC are both POSITIVE

// first 3 are inputs from the framebuffer
module vga_driver # (
    parameter H_VISIBLE_AREA = 800,
    parameter H_FRONT_PORCH = 56,
    parameter H_SYNC_PULSE = 120,
    parameter H_BACK_PORCH = 64,
    
    // calculated parameters
    parameter WHOLE_LINE = H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH,
    parameter CLOG2_WHOLE_LINE = $clog2(WHOLE_LINE),

    parameter V_VISIBLE_AREA = 600,
    parameter V_FRONT_PORCH = 37,
    parameter V_SYNC_PULSE = 6,
    parameter V_BACK_PORCH = 23,
    
    // calculated parameters
    parameter WHOLE_FRAME = V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH,
    parameter CLOG2_WHOLE_FRAME = $clog2(WHOLE_FRAME),

    // 1 for positive HSYNC pulse (i.e starts low goes high)
    // 0 for negative HSYNC pulse (i.e. starts high goes low)
    parameter HSYNC_POLARITY = 1'b0,
    parameter VSYNC_POLARITY = 1'b0
)
(
    input VGA_CLK,
    input [11:0] VGA_COLOR,
    output reg [3:0] VGA_B,
    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg VGA_HS,
    output reg VGA_VS,
    output [9:0] LEDR 
);

// there are 1040 pixels in a line, so we keep track of where we are
reg [CLOG2_WHOLE_LINE - 1 : 0] pixel_counter;

// there are 666 lines in the whole frame
reg [CLOG2_WHOLE_FRAME - 1 : 0] line_counter;

initial begin 
	pixel_counter = {CLOG2_WHOLE_LINE{1'b0}};
	line_counter = {CLOG2_WHOLE_FRAME{1'b0}};

    VGA_R = 4'b0000;
    VGA_G = 4'b0000;
    VGA_B = 4'b0000;

    VGA_VS = ~VSYNC_POLARITY;
    VGA_HS = ~HSYNC_POLARITY;
end

assign LEDR[9:0] = line_counter[9:0];

always @(posedge VGA_CLK) begin
    if ((line_counter >= 0) && (line_counter < V_FRONT_PORCH)) begin
        VGA_VS = ~VSYNC_POLARITY;

        VGA_R = 4'b0000;
        VGA_G = 4'b0000;
        VGA_B = 4'b0000;


        // TODO: use tasks to simplify pixel_counter logic?
        if ((pixel_counter >= 0) && (pixel_counter < H_FRONT_PORCH)) begin
            VGA_HS = ~HSYNC_POLARITY;
            pixel_counter <= pixel_counter + 1;

        end else if ((pixel_counter >= H_FRONT_PORCH) && (pixel_counter < (H_FRONT_PORCH + H_SYNC_PULSE))) begin
            VGA_HS = HSYNC_POLARITY;
            pixel_counter <= pixel_counter + 1;

        end else if ((pixel_counter >= (H_FRONT_PORCH + H_SYNC_PULSE)) && (pixel_counter < (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH))) begin
            VGA_HS = ~HSYNC_POLARITY;
            pixel_counter <= pixel_counter + 1;

        end else if ((pixel_counter >= (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH)) && (pixel_counter < (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH+ H_VISIBLE_AREA))) begin
            VGA_HS = ~HSYNC_POLARITY;
            // if last pixel then reset pixel counter to 0 here. else pixel_counter <= pixel_counter + 1;
            if (pixel_counter == (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH + H_VISIBLE_AREA - 1)) begin
                pixel_counter <= 0;
                line_counter <= line_counter + 1;
            end else begin
                pixel_counter <= pixel_counter + 1;
            end
        end

    end else if ((line_counter >= V_FRONT_PORCH) && (line_counter < (V_FRONT_PORCH + V_SYNC_PULSE))) begin
        VGA_VS = VSYNC_POLARITY;

        VGA_R = 4'b0000;
        VGA_G = 4'b0000;
        VGA_B = 4'b0000;

        if ((pixel_counter >= 0) && (pixel_counter < H_FRONT_PORCH)) begin
            VGA_HS = ~HSYNC_POLARITY;
            pixel_counter <= pixel_counter + 1;

        end else if ((pixel_counter >= H_FRONT_PORCH) && (pixel_counter < (H_FRONT_PORCH + H_SYNC_PULSE))) begin
            VGA_HS = HSYNC_POLARITY;
            pixel_counter <= pixel_counter + 1;

        end else if ((pixel_counter >= (H_FRONT_PORCH + H_SYNC_PULSE)) && (pixel_counter < (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH))) begin
            VGA_HS = ~HSYNC_POLARITY;
            pixel_counter <= pixel_counter + 1;

        end else if ((pixel_counter >= (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH)) && (pixel_counter < (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH+ H_VISIBLE_AREA))) begin
            VGA_HS = ~HSYNC_POLARITY;
            // if last pixel then reset pixel counter to 0 here. else pixel_counter <= pixel_counter + 1;
            if (pixel_counter == (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH + H_VISIBLE_AREA - 1)) begin
                pixel_counter <= 0;
                line_counter <= line_counter + 1;
            end else begin
                pixel_counter <= pixel_counter + 1;
            end
        end

    end else if ((line_counter >= (V_FRONT_PORCH + V_SYNC_PULSE)) && (line_counter < (V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH))) begin
        VGA_VS = ~VSYNC_POLARITY;

        VGA_R = 4'b0000;
        VGA_G = 4'b0000;
        VGA_B = 4'b0000;

        if ((pixel_counter >= 0) && (pixel_counter < H_FRONT_PORCH)) begin
            VGA_HS = ~HSYNC_POLARITY;
            pixel_counter <= pixel_counter + 1;

        end else if ((pixel_counter >= H_FRONT_PORCH) && (pixel_counter < (H_FRONT_PORCH + H_SYNC_PULSE))) begin
            VGA_HS = HSYNC_POLARITY;
            pixel_counter <= pixel_counter + 1;

        end else if ((pixel_counter >= (H_FRONT_PORCH + H_SYNC_PULSE)) && (pixel_counter < (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH))) begin
            VGA_HS = ~HSYNC_POLARITY;
            pixel_counter <= pixel_counter + 1;

        end else if ((pixel_counter >= (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH)) && (pixel_counter < (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH+ H_VISIBLE_AREA))) begin
            VGA_HS = ~HSYNC_POLARITY;
            // if last pixel then reset pixel counter to 0 here. else pixel_counter <= pixel_counter + 1;
            if (pixel_counter == (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH + H_VISIBLE_AREA - 1)) begin
                pixel_counter <= 0;
                line_counter <= line_counter + 1;
            end else begin
                pixel_counter <= pixel_counter + 1;
            end
        end        

    end else if ((line_counter >= (V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH)) && (line_counter < (V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH+ V_VISIBLE_AREA))) begin
        VGA_VS = ~VSYNC_POLARITY;

        if ((pixel_counter >= 0) && (pixel_counter < H_FRONT_PORCH)) begin
            VGA_HS = ~HSYNC_POLARITY;
            pixel_counter <= pixel_counter + 1;

            VGA_R = 4'b0000;
            VGA_G = 4'b0000;
            VGA_B = 4'b0000;

        end else if ((pixel_counter >= H_FRONT_PORCH) && (pixel_counter < (H_FRONT_PORCH + H_SYNC_PULSE))) begin
            VGA_HS = HSYNC_POLARITY;
            pixel_counter <= pixel_counter + 1;

            VGA_R = 4'b0000;
            VGA_G = 4'b0000;
            VGA_B = 4'b0000;

        end else if ((pixel_counter >= (H_FRONT_PORCH + H_SYNC_PULSE)) && (pixel_counter < (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH))) begin
            VGA_HS = ~HSYNC_POLARITY;
            pixel_counter <= pixel_counter + 1;

            VGA_R = 4'b0000;
            VGA_G = 4'b0000;
            VGA_B = 4'b0000;

        end else if ((pixel_counter >= (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH)) && (pixel_counter < (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH+ H_VISIBLE_AREA))) begin
            VGA_HS = ~HSYNC_POLARITY;
            // if last pixel then reset pixel counter to 0 here. else pixel_counter <= pixel_counter + 1;
            if (pixel_counter == (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH + H_VISIBLE_AREA - 1)) begin
                pixel_counter <= 0;
                // if last line then reset line counter to 0 here. else line_counter <= line_counter + 1;
                if (line_counter == (V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH + V_VISIBLE_AREA - 1)) begin
                    line_counter <= 0;
                end else begin
                    line_counter <= line_counter + 1;
                end
            end else begin
                pixel_counter <= pixel_counter + 1;
            end

            // set pixel color
            VGA_R = VGA_COLOR[11:8]; // e.g. 4'b1111 for full red
            VGA_G = VGA_COLOR[7:4]; // e.g. 4'b1111 for full green
            VGA_B = VGA_COLOR[3:0]; // e.g. 4'b1111 for full blue
        end
    end
end

endmodule
