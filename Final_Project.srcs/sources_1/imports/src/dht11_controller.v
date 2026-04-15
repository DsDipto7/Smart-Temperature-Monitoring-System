module dht11_controller (
input wire clk,
input wire rst,
input wire start,
inout wire dht_data,
output reg [7:0] temperature,
output reg [7:0] humidity,
output reg data_valid,
output reg error
);
localparam integer ONE_US = 100;
localparam integer START_LOW_US = 20_000;
localparam integer THRESHOLD_US = 40;
localparam integer TIMEOUT_US = 500;
localparam integer COOLDOWN_CLKS = 200_000_000;
localparam integer START_LOW_CNT = START_LOW_US * ONE_US;
localparam integer THRESHOLD_CNT = THRESHOLD_US * ONE_US;
localparam integer TIMEOUT_CNT = TIMEOUT_US * ONE_US;
localparam [3:0]
S_IDLE = 4'd0,
S_START_LOW = 4'd1,
S_START_RELEASE = 4'd2,
S_WAIT_RESP_LOW = 4'd3,
S_WAIT_RESP_HIGH = 4'd4,
S_RECV_WAIT_LOW = 4'd5,
S_RECV_WAIT_HIGH = 4'd6,
S_RECV_COUNT = 4'd7,
S_DONE = 4'd8,
S_ERROR = 4'd9,
S_COOLDOWN = 4'd10;
reg [3:0] state;
reg [20:0] cnt;
reg [20:0] high_cnt;
reg [5:0] bit_idx;
reg [39:0] sr;
reg [27:0] cd_cnt;
reg drive_low;
assign dht_data = drive_low ? 1'b0 : 1'bz;
reg sync_ff1, sync_ff2;
always @(posedge clk) begin
if (rst) begin
sync_ff1 <= 1'b1;
sync_ff2 <= 1'b1;
end else begin
sync_ff1 <= dht_data;
sync_ff2 <= sync_ff1;
end
end
wire data_in = sync_ff2;
wire [7:0] checksum_calc = sr[39:32] + sr[31:24] + sr[23:16] + sr[15:8];
always @(posedge clk) begin
if (rst) begin
state <= S_IDLE;
cnt <= 21'd0;
high_cnt <= 21'd0;
bit_idx <= 6'd0;
sr <= 40'd0;
cd_cnt <= 28'd0;
drive_low <= 1'b0;
temperature <= 8'd0;
humidity <= 8'd0;
data_valid <= 1'b0;
error <= 1'b0;
end else begin
data_valid <= 1'b0;
case (state)
S_IDLE: begin
drive_low <= 1'b0;
if (start) begin
state <= S_START_LOW;
cnt <= 21'd0;
end
end
S_START_LOW: begin
drive_low <= 1'b1;
if (cnt >= START_LOW_CNT - 1) begin
drive_low <= 1'b0;
state <= S_START_RELEASE;
cnt <= 21'd0;
end else begin
cnt <= cnt + 1'b1;
end
end
S_START_RELEASE: begin
drive_low <= 1'b0;
if (data_in == 1'b1) begin
state <= S_WAIT_RESP_LOW;
cnt <= 21'd0;
end else if (cnt >= TIMEOUT_CNT) begin
state <= S_ERROR;
end else begin
cnt <= cnt + 1'b1;
end
end
S_WAIT_RESP_LOW: begin
if (data_in == 1'b0) begin
state <= S_WAIT_RESP_HIGH;
cnt <= 21'd0;
end else if (cnt >= TIMEOUT_CNT) begin
state <= S_ERROR;
end else begin
cnt <= cnt + 1'b1;
end
end
S_WAIT_RESP_HIGH: begin
if (data_in == 1'b1) begin
state <= S_RECV_WAIT_LOW;
cnt <= 21'd0;
bit_idx <= 6'd0;
end else if (cnt >= TIMEOUT_CNT) begin
state <= S_ERROR;
end else begin
cnt <= cnt + 1'b1;
end
end
S_RECV_WAIT_LOW: begin
if (data_in == 1'b0) begin
state <= S_RECV_WAIT_HIGH;
cnt <= 21'd0;
end else if (cnt >= TIMEOUT_CNT) begin
state <= S_ERROR;
end else begin
cnt <= cnt + 1'b1;
end
end
S_RECV_WAIT_HIGH: begin
if (data_in == 1'b1) begin
state <= S_RECV_COUNT;
high_cnt <= 21'd0;
end else if (cnt >= TIMEOUT_CNT) begin
state <= S_ERROR;
end else begin
cnt <= cnt + 1'b1;
end
end
S_RECV_COUNT: begin
if (data_in == 1'b0) begin
sr <= {sr[38:0],
(high_cnt > THRESHOLD_CNT) ? 1'b1 : 1'b0};
bit_idx <= bit_idx + 1'b1;
cnt <= 21'd0;
if (bit_idx >= 6'd39)
state <= S_DONE;
else
state <= S_RECV_WAIT_HIGH;
end else if (high_cnt >= TIMEOUT_CNT) begin
state <= S_ERROR;
end else begin
high_cnt <= high_cnt + 1'b1;
end
end
S_DONE: begin
if (checksum_calc == sr[7:0]) begin
humidity <= sr[39:32];
temperature <= sr[23:16];
data_valid <= 1'b1;
error <= 1'b0;
end else begin
error <= 1'b1;
end
state <= S_COOLDOWN;
cd_cnt <= 28'd0;
end
S_ERROR: begin
error <= 1'b1;
drive_low <= 1'b0;
state <= S_COOLDOWN;
cd_cnt <= 28'd0;
end
S_COOLDOWN: begin
drive_low <= 1'b0;
if (cd_cnt >= COOLDOWN_CLKS) begin
state <= S_IDLE;
end else begin
cd_cnt <= cd_cnt + 1'b1;
end
end
default: state <= S_IDLE;
endcase
end
end
endmodule
