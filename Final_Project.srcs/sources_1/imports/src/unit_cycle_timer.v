module unit_cycle_timer (
input wire clk,
input wire rst,
output reg [1:0] unit_sel
);
localparam integer CYCLE_PERIOD = 500_000_000;
reg [28:0] cycle_cnt;
always @(posedge clk) begin
if (rst) begin
cycle_cnt <= 29'd0;
unit_sel <= 2'd0;
end else if (cycle_cnt >= CYCLE_PERIOD - 1) begin
cycle_cnt <= 29'd0;
if (unit_sel >= 2'd2)
unit_sel <= 2'd0;
else
unit_sel <= unit_sel + 1'b1;
end else begin
cycle_cnt <= cycle_cnt + 1'b1;
end
end
endmodule
