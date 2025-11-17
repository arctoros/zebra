module VGA(
	 input wire [7:0] DATA,
    input CLK,
    output reg HSYNC,
    output reg VSYNC,
	 output INT,
	 output RW,
	 output reg [14:0] ADDR,
	 output reg [11:0] RGB
	);
	 	
	reg [9:0] CounterX;
 	reg [9:0] CounterY;
	
	assign INT = 1;
	assign RW = 1;
	
	wire CounterXwrap = (CounterX == 800); // 16 + 48 + 96 + 640
	wire CounterYwrap = (CounterY == 449); // 10 + 2 + 33 + 480

	always @(posedge CLK) begin
   	if (CounterXwrap) begin
			CounterX <= 0;
			CounterY <= CounterY + 1;
		end else
   		CounterX <= CounterX + 1;
		
      if (CounterYwrap) begin
        CounterY <= 0;
		  ADDR <= 0;
		end

		HSYNC <= ~((CounterX >= 656) && (CounterX < 752));   // active for 96 clocks
		VSYNC <= ~((CounterY >= 412) && (CounterY < 414));   // active for 2 clocks

		if (!CounterY[0] && CounterXwrap)
				ADDR <= ADDR - 160;
		
		if ((CounterX < 640) && (CounterY < 400)) begin
			if (CounterX[1:0] == 3)
				ADDR <= ADDR + 1;

			case (CounterX[1] ? DATA[3:0] : DATA[7:4])
				0 : RGB <= 12'b000000000000; // (00,00,00)
				1 : RGB <= 12'b001100110010; // (03,03,02)
				2 : RGB <= 12'b010001011010; // (04,05,10)
				3 : RGB <= 12'b010010011011; // (04,09,11)
				4 : RGB <= 12'b001101010010; // (03,05,02)
				5 : RGB <= 12'b011110010100; // (08,09,05)
				6 : RGB <= 12'b010101100010; // (05,06,02)
				7 : RGB <= 12'b011001110011; // (06,07,03)
				8 : RGB <= 12'b011001100101; // (06,06,05)
				9 : RGB <= 12'b011001010011; // (06,05,03)
			  10 : RGB <= 12'b111010110001; // (14,11,01)
			  11 : RGB <= 12'b100101010011; // (09,05,03)
			  12 : RGB <= 12'b100000110011; // (08,03,03)
			  13 : RGB <= 12'b101110011001; // (11,09,09)
			  14 : RGB <= 12'b111011011100; // (14,13,12)
			  15 : RGB <= 12'b111111111111; // (15,15,15)
			endcase
		end else
			RGB <= 12'b000000000000;
	end
endmodule