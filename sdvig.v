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


module sdvig
(
	input clk,
	input key0,
	input key2,
	input sw0,
	output LEDS

);

wire push0, push2;
reg [7:0] byte;

key key_0
(
	.clk	(clk),
	.key0	(key0),
	.push	(push0)
);

key key_2
(
	.clk	(clk),
	.key0	(key2),
	.push	(push2)

);


always @(posedge clk)
begin
	if (push0)
		byte <= 0;
	else if (push2)
		byte <= (byte << 1) + sw0;	
end

assign LEDS = byte;

endmodule