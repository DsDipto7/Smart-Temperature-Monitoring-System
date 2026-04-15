module top_module (
input wire clk,
input wire rst,
inout wire jA1,
output wire [6:0] seg,
output wire dp,
output wire [3:0] an,
output wire led_hot,
output wire led_cold,
output wire buzzer_out
);
parameter [7:0] TEMP_THRESHOLD = 8'd40;
wire [7:0] temperature;
wire [7:0] humidity;
wire data_valid;
wire dht_error;
wire [1:0] unit_sel;
wire [15:0] display_value;
wire temp_above;
localparam integer TRIGGER_PERIOD = 200_000_000;
reg [27:0] trigger_cnt;
reg start_pulse;
always @(posedge clk) begin
if (rst) begin
trigger_cnt <= 28'd0;
start_pulse <= 1'b0;
end else if (trigger_cnt >= TRIGGER_PERIOD - 1) begin
trigger_cnt <= 28'd0;
start_pulse <= 1'b1;
end else begin
trigger_cnt <= trigger_cnt + 1'b1;
start_pulse <= 1'b0;
end
end
dht11_controller u_dht11 (
.clk (clk),
.rst (rst),
.start (start_pulse),
.dht_data (jA1),
.temperature (temperature),
.humidity (humidity),
.data_valid (data_valid),
.error (dht_error)
);
assign temp_above = (temperature > TEMP_THRESHOLD);
assign led_hot = temp_above;
assign led_cold = ~temp_above;
unit_cycle_timer u_unit_timer (
.clk (clk),
.rst (rst),
.unit_sel (unit_sel)
);
temp_alu u_alu (
.temp_celsius (temperature),
.op_sel (unit_sel),
.result (display_value)
);
seven_seg_driver u_ssd (
.clk (clk),
.rst (rst),
.display_value (display_value),
.unit_sel (unit_sel),
.seg (seg),
.dp (dp),
.an (an)
);
buzzer_controller u_buzzer (
.clk (clk),
.rst (rst),
.temp_above (temp_above),
.buzzer_out (buzzer_out)
);
endmodule
