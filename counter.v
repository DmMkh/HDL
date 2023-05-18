module key
(
	input clk,
	input keyy,
	output push
);

reg but_r, but_rr;

always @(posedge clk)
begin
	but_r <= keyy;
	but_rr <= but_r;
end

assign push = but_r & ~but_rr;

endmodule


module binary2
(
	input [2:0] counter,
	output [7:0] binary
);

assign binary = (1 << counter) - 1;

endmodule

module diode
(
	input clk,
	input key0,
	input key1,
	output [7:0] LEDS
);

reg [2:0] counter;
wire push0, push1, push2;

key key0
(
	.clk	(clk),
	.keyy	(key0),
	.push	(push0)
);

key key1
(
	.clk	(clk),
	.keyy	(key1),
	.push	(push1)
);

key key2
(
	.clk	(clk),
	.keyy	(key2),
	.push	(push2)
);

binary2 binary_2
(
	.counter	(counter),
	.binary		(LEDS)
);

always @(posedge clk)
begin
	if (push1)
		counter <= counter + 1;
	else if (push0)
		counter <= 0;
	else if (push2)
		counter <= counter - 1;

end

endmodule












