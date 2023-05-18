module key
(
	input clk,
	input key0,
	output push
);
reg but_r;
reg but_rr;
always @(posedge clk)
begin
	but_r <= key0;
	but_rr <= but_r;
end
	assign push = ~but_rr & but_r;
endmodule


module dio
(
	input clk,
	input key0,
	input key1,
	input key2,
	input [8:0] sw,
	output [7:0] LEDS,
	output [7:0] LEDG

);

wire push0, push1, push2;
reg [7:0] byte;
reg [7:0] byte2;

key key_0
(
	.clk	(clk),
	.key0	(key0),
	.push	(push0)
);

key key_1
(
	.clk	(clk),
	.key0	(key1),
	.push	(push1)

);

key key_2
(
	.clk	(clk),
	.key0	(key2),
	.push	(push2)
);

always @(posedge clk)
begin
	if (push1 & key0)
		byte[7:0] <= sw[7:0];
	else if (push2 & key0)
	begin
		byte2 <= {LEDS[0], byte2[7:1]};
		byte <= {sw[8], byte[7:1]};
	end
	else if (push0)
	begin
		byte2 <= 0;
		byte <= 0;
	end
end

assign LEDS = byte;
assign LEDG = byte2;

endmodule