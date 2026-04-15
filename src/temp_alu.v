module temp_alu (
input wire [7:0] temp_celsius,
input wire [1:0] op_sel,
output reg [15:0] result
);
wire [15:0] celsius_x9;
wire [15:0] fahrenheit_val;
assign celsius_x9 = temp_celsius * 4'd9;
assign fahrenheit_val = (celsius_x9 / 4'd5) + 8'd32;
wire [15:0] kelvin_val;
assign kelvin_val = temp_celsius + 16'd273;
always @(*) begin
case (op_sel)
2'b00: result = {8'd0, temp_celsius};
2'b01: result = fahrenheit_val;
2'b10: result = kelvin_val;
default: result = 16'd0;
endcase
end
endmodule
