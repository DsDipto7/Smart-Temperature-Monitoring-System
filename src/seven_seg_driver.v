module seven_seg_driver (
input wire clk,
input wire rst,
input wire [15:0] display_value,
input wire [1:0] unit_sel,
output reg [6:0] seg,
output reg dp,
output reg [3:0] an
);
localparam integer REFRESH_MAX = 100_000;
reg [16:0] refresh_cnt;
reg [1:0] digit_sel;
always @(posedge clk) begin
if (rst) begin
refresh_cnt <= 17'd0;
digit_sel <= 2'd0;
end else if (refresh_cnt >= REFRESH_MAX - 1) begin
refresh_cnt <= 17'd0;
digit_sel <= digit_sel + 1'b1;
end else begin
refresh_cnt <= refresh_cnt + 1'b1;
end
end
wire [3:0] hundreds = display_value / 100;
wire [3:0] tens = (display_value % 100) / 10;
wire [3:0] ones = display_value % 10;
function [6:0] bcd_to_seg;
input [3:0] digit;
case (digit)
4'd0: bcd_to_seg = 7'b1000000;
4'd1: bcd_to_seg = 7'b1111001;
4'd2: bcd_to_seg = 7'b0100100;
4'd3: bcd_to_seg = 7'b0110000;
4'd4: bcd_to_seg = 7'b0011001;
4'd5: bcd_to_seg = 7'b0010010;
4'd6: bcd_to_seg = 7'b0000010;
4'd7: bcd_to_seg = 7'b1111000;
4'd8: bcd_to_seg = 7'b0000000;
4'd9: bcd_to_seg = 7'b0010000;
default: bcd_to_seg = 7'b1111111;
endcase
endfunction
localparam [6:0] CHAR_C = 7'b1000110;
localparam [6:0] CHAR_F = 7'b0001110;
localparam [6:0] CHAR_K = 7'b0001001;
localparam [6:0] CHAR_BLANK = 7'b1111111;
reg [6:0] unit_char;
always @(*) begin
case (unit_sel)
2'b00: unit_char = CHAR_C;
2'b01: unit_char = CHAR_F;
2'b10: unit_char = CHAR_K;
default: unit_char = CHAR_BLANK;
endcase
end
always @(*) begin
dp = 1'b1;
case (digit_sel)
2'd3: begin
an = 4'b0111;
seg = (hundreds == 4'd0) ? CHAR_BLANK : bcd_to_seg(hundreds);
end
2'd2: begin
an = 4'b1011;
seg = (hundreds == 4'd0 && tens == 4'd0) ? CHAR_BLANK : bcd_to_seg(tens);
end
2'd1: begin
an = 4'b1101;
seg = bcd_to_seg(ones);
end
2'd0: begin
an = 4'b1110;
seg = unit_char;
end
default: begin
an = 4'b1111;
seg = CHAR_BLANK;
end
endcase
end
endmodule
