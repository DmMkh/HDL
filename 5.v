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
	input [15:0] sw,
	output [15:0] LEDR,
	output [7:0] LEDG

);

wire push0, push1;
reg [7:0] summ;

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

always @(posedge clk)
begin
	if (push1 & key0)
		summ <= sw[15:8] + sw[7:0];
	else if (~key0)
		summ <= 0;
end

assign LEDR[7:0] = sw[7:0];
assign LEDR[15:8] = sw[15:8];
assign LEDG = summ;


endmodule