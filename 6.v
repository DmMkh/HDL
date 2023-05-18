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

module hex2sem
(
	input [3:0] hex,
	output [6:0] segm
);
assign segm = (hex == 4'h0) ? 7'b1000000 :
		(hex == 4'h1) ? 7'b1111001 :
		(hex == 4'h2) ? 7'b0100100 :
		(hex == 4'h3) ? 7'b0110000 :
		(hex == 4'h4) ? 7'b0011001 :
		(hex == 4'h5) ? 7'b0010010 :
		(hex == 4'h6) ? 7'b0000010 :
		(hex == 4'h7) ? 7'b1111000 :
		(hex == 4'h8) ? 7'b0000000 :
		(hex == 4'h9) ? 7'b0010000 :
		(hex == 4'ha) ? 7'b0001000 :
		(hex == 4'hb) ? 7'b0000011 :
		(hex == 4'hc) ? 7'b1000110 :
		(hex == 4'hd) ? 7'b0100001 :
		(hex == 4'he) ? 7'b0000110 :
		(hex == 4'hf) ? 7'b0001110 : 7'b0001110;
endmodule


module dio
(
	input clk,
	input key0,
	input key1,
	input [15:0] sw,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LEDG8

);

wire push1;
reg [8:0] summ;


key key_1
(
	.clk	(clk),
	.key0	(key1),
	.push	(push1)
);

hex2sem hex24
(
	.hex	(sw[3:0]),
	.segm	(HEX4)

);

hex2sem hex25
(
	.hex	(sw[7:4]),
	.segm	(HEX5)

);

hex2sem hex26
(
	.hex	(sw[11:8]),
	.segm	(HEX6)

);

hex2sem hex27
(
	.hex	(sw[15:12]),
	.segm	(HEX7)

);

hex2sem hex22
(
	.hex	(summ[3:0]),
	.segm	(HEX2)

);

hex2sem hex23
(
	.hex	(summ[7:4]),
	.segm	(HEX3)

);



always @(posedge clk)
begin
	if (push1 & key0)
		summ <= sw[15:8] + sw[7:0];
	else if (~key0)
		summ <= 0;
end
		assign LEDG8 = summ[8];


endmodule 