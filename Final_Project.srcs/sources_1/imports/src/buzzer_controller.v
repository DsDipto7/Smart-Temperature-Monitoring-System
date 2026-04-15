module buzzer_controller (
input wire clk,
input wire rst,
input wire temp_above,
output reg buzzer_out
);
localparam integer BEEP_CYCLES = 500_000_000;
localparam [1:0]
S_IDLE = 2'd0,
S_BEEPING = 2'd1,
S_WAIT = 2'd2;
reg [1:0] state;
reg [28:0] beep_cnt;
always @(posedge clk) begin
if (rst) begin
state <= S_IDLE;
beep_cnt <= 29'd0;
buzzer_out <= 1'b0;
end else begin
case (state)
S_IDLE: begin
buzzer_out <= 1'b0;
beep_cnt <= 29'd0;
if (temp_above) begin
state <= S_BEEPING;
buzzer_out <= 1'b1;
end
end
S_BEEPING: begin
buzzer_out <= 1'b1;
if (!temp_above) begin
state <= S_IDLE;
buzzer_out <= 1'b0;
beep_cnt <= 29'd0;
end else if (beep_cnt >= BEEP_CYCLES - 1) begin
state <= S_WAIT;
buzzer_out <= 1'b0;
beep_cnt <= 29'd0;
end else begin
beep_cnt <= beep_cnt + 1'b1;
end
end
S_WAIT: begin
buzzer_out <= 1'b0;
if (!temp_above) begin
state <= S_IDLE;
end else begin
state <= S_BEEPING;
buzzer_out <= 1'b1;
beep_cnt <= 29'd0;
end
end
default: begin
state <= S_IDLE;
buzzer_out <= 1'b0;
beep_cnt <= 29'd0;
end
endcase
end
end
endmodule
