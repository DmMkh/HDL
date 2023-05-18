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
	input key2,
	input key3,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX1,
	output [6:0] HEX4,
	output [6:0] HEX5

);

wire push1, push2, push3;
reg [22:0] counter;
reg [3:0] sec;
reg [3:0] tsec;
reg [3:0] msec;

reg [3:0] p1tsec;
reg [3:0] p1sec;

reg [3:0] p2tsec;
reg [3:0] p2sec;

reg [3:0] p3tsec;
reg [3:0] p3sec;

reg [3:0] p4tsec;
reg [3:0] p4sec;

reg [3:0] showsec;
reg [3:0] showtsec;

reg [1:0] num;
reg [2:0] show;

reg flag;

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

key key_3
(
	.clk	(clk),
	.key0	(key3),
	.push	(push3)

);
hex2sem hex22
(
	.hex	(sec[3:0]),
	.segm	(HEX2)

);

hex2sem hex23
(
	.hex	(tsec[3:0]),
	.segm	(HEX3)

);

hex2sem hex21
(
	.hex	(msec[3:0]),
	.segm	(HEX1)

);

hex2sem hex24
(
	.hex	(showsec[3:0]),
	.segm	(HEX4)

);

hex2sem hex25
(
	.hex	(showtsec[3:0]),
	.segm	(HEX5)

);


always @(posedge clk)
begin
	if (~key0)
	begin
		counter <= 0;
		sec <= 0;
		tsec <= 0;
		msec <= 0;
		p1sec <= 0;
		p1tsec <= 0;
		p2sec <= 0;
		p2tsec <= 0;
		p3sec <= 0;
		p3tsec <= 0;
		p4sec <= 0;
		p4tsec <= 0;
		showsec <= 0;
		showtsec <= 0;
		num <= 0;
	end
	else
	begin
		if (push1)
			flag <= ~flag;
		if (push2 & ~flag)						//reset data
		begin
			p1sec <= 0;
			p1tsec <= 0;
			p2sec <= 0;
			p2tsec <= 0;
			p3sec <= 0;
			p3tsec <= 0;
			p4sec <= 0;
			p4tsec <= 0;
			showsec <= 0;
			showtsec <= 0;
		end
		else if (push2)							//set data
		begin
			if (num == 0)
			begin
				p1sec <= sec;
				p1tsec <= tsec;
				showsec <= sec;
				showtsec <= tsec;
				num <= num + 1;
			end
			else if (num == 1)
			begin
				p2sec <= sec;
				p2tsec <= tsec;
				showsec <= sec;
				showtsec <= tsec;
				num <= num + 1;
			end
			else if (num == 2)
			begin
				p3sec <= sec;
				p3tsec <= tsec;
				showsec <= sec;
				showtsec <= tsec;
				num <= num + 1;
			end
			else if (num == 3)
			begin
				p4sec <= sec;
				p4tsec <= tsec;
				showsec <= sec;
				showtsec <= tsec;
				num <= num + 1;
			end
		end
		if (flag == 1)							//count seconds
			if (counter < 25'd5000000)
				counter <= counter + 1;
			else
			begin
				counter <= 0;
				if (msec != 9)
					msec <= msec + 1;
				else if (sec != 9)
				begin
					msec <= 0;
					sec <= sec + 1;
				end
				else if(tsec != 9)
				begin
					msec <= 0;
					sec <= 0;
					tsec <= tsec + 1;				
				end
				else
				begin
					msec <= 0;
					sec <= 0;
					tsec <= 0;			
				end
			end
		if (push3 & ~flag)			//show data
		begin
			if (show == 0)
			begin
				showsec <= p1sec;
				showtsec <= p1tsec;
				show <= show + 1;
			end
			else if (show == 1)
			begin
				showsec <= p2sec;
				showtsec <= p2tsec;
				show <= show + 1;
			end
			else if (show == 2)
			begin
				showsec <= p3sec;
				showtsec <= p3tsec;
				show <= show + 1;
			end
			else if (show == 3)
			begin
				showsec <= p4sec;
				showtsec <= p4tsec;
				show <= show + 1;
			end
			else 
			begin
				showsec <= sec;
				showtsec <= tsec;
				show <= 0;
			end
		end
	end
end


endmodule 