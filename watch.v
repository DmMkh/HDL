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
	assign push = but_rr & ~but_r;
endmodule

module coder
(
	input [3:0] word,
	output [15:0] code
);

assign code = (word == 0) ? 16'b00110000:
					(word == 1) ? 16'b00110001:
					(word == 2) ? 16'b00110010:
					(word == 3) ? 16'b00110011:
					(word == 4) ? 16'b00110100:
					(word == 5) ? 16'b00110101:
					(word == 6) ? 16'b00110110:
					(word == 7) ? 16'b00110111:
					(word == 8) ? 16'b00111000:16'b00111001;

endmodule

module dio
(
	input clk,
	input key0,
	input key1,
	input key2,
	input key3,
	output [7:0] LCD_DataBus,
	output LCD_RS, 
	output LCD_RW, 
	output LCD_EN, 
	output LCD_ON,
	output LEDG8
);

reg LED;
reg [33:0] counter;
reg [33:0] watch;
reg [14:0] count;
reg [7:0] write_counter;
reg RS;
reg RW;
reg EN;
reg ON;
reg restart;
reg write;
reg [7:0] DATA;
reg [7:0] buff;
reg [3:0] dat;
reg [3:0] word;
reg [15:0] codee;
reg [3:0] sec;
reg [3:0] tsec;
reg [3:0] min;
reg [3:0] tmin;
reg [3:0] hour;
reg [3:0] thour;
reg [2:0] num;

reg flag;


wire push0, push1, push2, push3;
wire [15:0] code;

assign LCD_RS = RS;
assign LCD_RW = RW;
assign LCD_EN = EN;
assign LCD_ON = ON;
assign LCD_DataBus = DATA;
assign LEDG8 = LED;

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

key key_3
(
	.clk	(clk),
	.key0	(key3),
	.push	(push3)

);

coder coder1
(
	.word	(word),
	.code	(code)
);


always @(posedge clk)
begin



	if (~key0)
	begin
		counter <= 0;
		sec <= 0;
		//watch <= 0;
		min <= 0;
		tsec <= 0;
		tmin <= 0;
		hour <= 0;
		thour <= 0;
		flag <= 0;
	end
	else if (push1)
		flag <= ~flag;
	else if (flag == 1)							//count seconds
			if (watch < 50000000)
				watch <= watch + 1;
			else
			begin
				watch <= 0;
				if (sec != 9)
					sec <= sec + 1;
				else if (tsec != 5)
				begin
					sec <= 0;
					tsec <= tsec + 1;
				end
				else if (min != 9)
				begin
					min <= min + 1;
					sec <= 0;
					tsec <= 0;
				end
				else if (tmin != 5)
				begin
					tmin <= tmin + 1;
					sec <= 0;
					tsec <= 0;
					min <= 0;
				end
				else if (thour == 2 && hour == 3)
				begin
					sec <= 0;
					tsec <= 0;
					tmin <= 0;
					min <= 0;
					hour <= 0;
					thour <= 0;
				end
				else if (hour != 9)
				begin
					sec <= 0;
					tsec <= 0;
					tmin <= 0;
					min <= 0;
					hour <= hour + 1;				
				end
				else 
				begin
					sec <= 0;
					tsec <= 0;
					min <= 0;
					tmin <= 0;
					hour <= 0;
					thour <= thour + 1;			
				end
			end
	else if (push2)
		num <= num + 1;
	else if (push3)
		if (num == 0)
			if (sec != 9)
				sec <= sec + 1;
			else 
				sec <= 0;
		else if (num == 1)
			if (tsec != 5)
				tsec <= tsec + 1;
			else tsec <= 0;
		else if (num == 2)
			if (min != 9)
				min <= min + 1;
			else 
				min <= 0;
		else if (num == 3)
			if (tmin != 5)
				tmin <= tmin + 1;
			else 
				tmin <= 0;
		else if (num == 4)
			if ((hour != 9 && thour != 2) || (thour == 2 && hour < 3))
				hour <= hour + 1;
			else
				hour <= 0;
		else if (num == 5)
		begin
			if (thour == 1 && hour > 3)
				thour <= 0;
			else if (thour == 2)
				thour <= 0;
			else		
				thour <= thour + 1;
			//num <= 7;
		end
		else if (num == 6)
			num <= 0;
			
	if (push0)
	begin
		restart <= 0;
		counter <= 0;
		write_counter <= 0;
		EN <= 0;
		RW <= 0;
		RS <= 0;
		ON <= 0;
		DATA <= 0;
		write <= 0;
		buff <= 0;
		dat <= 0;
	end
	else	
	begin
		counter <= counter + 1;		// instructions for LCD
		count <= count + 1;
	end
	if (restart == 0)
	begin
		LED <= 1;
		if (counter == 2)
		begin
			EN <= 0;
			RS <= 0;
			RW <= 0;
			ON <= 1;
			DATA <= 16'b00111000;
			write <= 1;
		end
		else if (count == 130)
		begin
//			write <= 1;
			DATA <= 16'b00001110;
			write <= 1;
		end
		
		else if (count == 260)
		begin
			DATA <= 16'b00000001;
			write <= 1;
		end
		else if (count == 400)
		begin
			RS <= 1;
			restart <= 1;
		end	
	end
	
	
	if (write)
	begin
		LED <= 0;
		write_counter <= write_counter + 1;					//write to LCD
		if (write_counter == 1)
		begin
			EN <= 0;
			DATA <= buff;
		end
		else if (write_counter == 20)
			EN <= 1;
		else if (write_counter == 95)
			EN <= 0;
		else if (write_counter == 115)
		begin
			write_counter <= 0;
			write <= 0;
		end
	end
	
	
	if (!count)						// LCD OUT
	begin
		dat <= dat + 1;
		if (dat == 4)
		begin
			word <= tsec;
			buff <= code;
			RS <= 1;
		end
		if (dat == 6)
		begin
			word <= sec;
			buff <= code;
			RS <= 1;
		end
		if (dat == 5)
		begin
			buff <= 16'b00111010;
			RS <= 1;
		end
		if (dat == 7)
		begin
			word <= thour;
			buff <= code;
			RS <= 1;
		end
		if (dat == 8)
		begin
			buff <= 16'b00000010;
			RS <= 0;
			dat <= 15;
		end
		if (dat == 1)
		begin
			word <= tmin;
			buff <= code;
			RS <= 1;
		end
		if (dat == 2) 
		begin 
			buff <= 16'b00111010;
			RS <= 1;
		end
		if (dat == 3)
		begin
			word <= min;
			buff <= code;
			RS <= 1;
		end
		if (dat == 0)
		begin
			word <= hour;
			buff <= code;
			RS <= 1;
		end
		write <= 1;
	end
end


endmodule