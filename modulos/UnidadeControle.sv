module UnidadeControle(
	input logic clk, 
	input logic reset,
	input logic [31:0] Instr,
	input logic [6:0] OPcode,
	input logic [6:0] func7,
	input logic [2:0] func3,

	output logic [4:0] stateout,
	output logic [1:0] Shift,
	output logic Wrl,
	output logic WrD,
	output logic RegWrite,
	output logic LoadIR,
	output logic [2:0]MemToReg,
	output logic [1:0] ALUSrcA,
	output logic [1:0] ALUSrcB,
	output logic [2:0] ALUFct,
	output logic PCWrite,
	output logic PCWriteCondbeq,
	output logic PCWriteCondbne,
	output logic PCWriteCondbge,
	output logic PCWriteCondblt,
	output logic PCSource,
	output logic LoadRegA,
	output logic LoadRegB,
	output logic LoadAOut,
	output logic LoadMDR,
	output logic flagCausa,
	output logic causa,
	output logic muxInstr
);

logic [4:0] inicio = 5'b00000; //0
logic [4:0] BInst = 5'b00001; //1
logic [4:0] IDecod = 5'b00010; //2
logic [4:0] Cem = 5'b00011; //3
logic [4:0] Amld = 5'b00100; //4
logic [4:0] Ev = 5'b00101; //5
logic [4:0] Amsd = 5'b00110; //6
logic [4:0] Exeadd = 5'b00111; //7
logic [4:0] Exesub = 5'b01000; //8
logic [4:0] Cr = 5'b01001; //9
logic [4:0] Crcbeq = 5'b01010; //10
logic [4:0] Crcbne = 5'b01011; //11
logic [4:0] Lui = 5'b01100; //12
logic [4:0] Exeand = 5'b01101; //13
logic [4:0] Exeslt = 5'b01110; //14
logic [4:0] Crcbge = 5'b01111; //15
logic [4:0] Crcblt = 5'b10000; //16
logic [4:0] Srli = 5'b10001; //17
logic [4:0] Srai = 5'b10010; //18
logic [4:0] Slli = 5'b10011; //19
logic [4:0] Break = 5'b10100; //20
logic [4:0] Exeslti = 5'b10101; //21
logic [4:0] Crcjal = 5'b10110; //22
logic [4:0] DecodJalr = 5'b10111; //23
logic [4:0] Crcjalr = 5'b11000; //24
logic [4:0] exc = 5'b11001; //25
logic [4:0] exc2 = 5'b11010; //26
logic [4:0] exc3 = 5'b11011; //27

logic [4:0] state; 
logic [4:0] nextState;

assign stateout = state;

always_ff@(posedge clk, posedge reset) begin
	if(reset)begin
		state <= inicio;
	end else begin 
		state <= nextState;
	end
end

always_comb begin
	case(state)
		inicio: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b00;
			ALUFct = 3'b000;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b0;
			LoadMDR = 1'b0;
			muxInstr = 1'b0;
			nextState = BInst;
		end
		
		BInst: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b1;
			MemToReg = 3'b000;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b01;
			ALUFct = 3'b001;
			PCWrite = 1'b1;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b0;
			LoadMDR = 1'b0;
			nextState = IDecod;
		end

		IDecod: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b1;
			MemToReg = 3'b000;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b11;
			ALUFct = 3'b001;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b1;
			LoadRegB = 1'b1;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;

			if(Instr == 32'b00000000000000000000000000010011) begin
				nextState = inicio;
			end
			else begin
				case(OPcode)

					7'b0110011: begin //Tipo R
						case(func7)

							7'b0000000: begin
								case(func3)
									3'b000: begin
										nextState = Exeadd;
									end
									3'b010: begin
										nextState = Exeslt;
									end
									3'b111: begin
										nextState = Exeand;
									end
								endcase
							end

							7'b0100000: begin
								nextState = Exesub;
							end

							default: begin
								nextState = inicio;
							end
						endcase
					end

					7'b0010011: begin //addi
						case(func3)
							3'b000: begin
								nextState = Cem;
							end
							3'b101: begin
								if(func7[5] == 1'b0) begin // Srli
									nextState = Srli;
								end 
								else begin // Srai
									nextState = Srai;
								end 
							end
							3'b001: begin // Slli
								nextState = Slli;
							end

							3'b010: begin //slti
								nextState = Exeslti;
							end

							default: begin
								nextState = inicio;
							end
							
						endcase
					end

					7'b0000011: begin //Loads
						nextState = Cem;
					end

					7'b0100011: begin //sd
						nextState = Cem;
					end

					7'b1100011: begin //beq
						case(func3)
							3'b000: begin
								nextState = Crcbeq;
							end
							default: begin
								nextState = inicio;
							end
						endcase
					end

					7'b1100111: begin //bne && bge && blt
						case(func3)
							3'b001: begin // bne
								nextState = Crcbne;
							end
							3'b101: begin // bge
								nextState = Crcbge;
							end
							3'b100: begin // blt
								nextState = Crcblt;
							end
							3'b000: begin // jalr
								nextState = DecodJalr;
							end 
							default: begin
								nextState = inicio;
							end
						endcase
					end

					7'b1101111: begin // jal
						nextState = Crcjal;
					end

					7'b0110111: begin //lui
						nextState = Lui;
					end

					7'b1110011: begin //break
						nextState = Break;
					end

					default: begin
						nextState = exc;
					end
				endcase
			end
		end

		Cem: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b01;
			ALUSrcB = 2'b10;
			ALUFct = 3'b001;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;;

			if(OPcode == 7'b0000011 || OPcode == 7'b0100011) begin
				nextState = Amld;
			end

			else if(OPcode == 7'b0010011) begin
				if(func3 == 3'b000) begin
					nextState = Cr;
				end
				else nextState = inicio;
			end
		end

		Amld: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b00;
			ALUFct = 3'b000;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b0;
			LoadMDR = 1'b0;

			if(OPcode == 7'b0100011) begin
				nextState = Amsd;
			end
			else if(OPcode == 7'b0000011) begin
				nextState = Ev;
			end
			else begin
				nextState = inicio;
			end
		end

		Ev: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b1;
			LoadIR = 1'b0;
			MemToReg = 3'b001;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b00;
			ALUFct = 3'b000;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b0;
			LoadMDR = 1'b1;
			nextState = inicio;
		end

		Amsd: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b1;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b00;
			ALUFct = 3'b000;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b0;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		Exeadd: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b01;
			ALUSrcB = 2'b00;
			ALUFct = 3'b001;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;
			nextState = Cr;			
		end

		Exesub: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b01;
			ALUSrcB = 2'b00;
			ALUFct = 3'b010;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;
			nextState = Cr;	
		end

		Cr: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b1;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b00;
			ALUFct = 2'b00;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		Crcbeq: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b01;
			ALUSrcB = 2'b00;
			ALUFct = 3'b010;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b1;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b1;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		Crcbne: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b01;
			ALUSrcB = 2'b00;
			ALUFct = 3'b010;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b1;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b1;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		Crcbge: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b01;
			ALUSrcB = 2'b00;
			ALUFct = 3'b111;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b1;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b1;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		Crcblt: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b01;
			ALUSrcB = 2'b00;
			ALUFct = 3'b111;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b1;
			PCSource = 1'b1;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		Lui: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b1;
			LoadIR = 1'b0;
			MemToReg = 3'b010;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b00;
			ALUFct = 3'b000;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b0;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		Exeand: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b01;
			ALUSrcB = 2'b00;
			ALUFct = 3'b011;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;
			nextState = Cr;
		end

		Exeslt: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b1;
			LoadIR = 1'b0;
			MemToReg = 3'b010;
			ALUSrcA = 2'b01;
			ALUSrcB = 2'b00;
			ALUFct = 3'b111;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b0;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		Exeslti: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b1;
			LoadIR = 1'b0;
			MemToReg = 3'b010;
			ALUSrcA = 2'b01;
			ALUSrcB = 2'b10;
			ALUFct = 3'b111;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b0;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		Srli: begin
			Shift = 2'b01;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b1;
			LoadIR = 1'b0;
			MemToReg = 3'b011;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b00;
			ALUFct = 3'b000;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b0;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		Srai: begin
			Shift = 2'b10;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b1;
			LoadIR = 1'b0;
			MemToReg = 3'b011;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b00;
			ALUFct = 3'b000;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b0;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		Slli: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b1;
			LoadIR = 1'b0;
			MemToReg = 3'b011;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b00;
			ALUFct = 3'b000;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b0;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		Crcjal: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b1;
			LoadIR = 1'b0;
			MemToReg = 3'b100;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b11;
			ALUFct = 3'b001;
			PCWrite = 1'b1;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b1;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		DecodJalr: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b100;
			ALUSrcA = 2'b01;
			ALUSrcB = 2'b10;
			ALUFct = 3'b001;
			PCWrite = 1'b0;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b0;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;
			nextState = Crcjalr;
		end

		Crcjalr: begin
			Shift = 2'b00;
			Wrl = 1'b0;
			WrD = 1'b0;
			RegWrite = 1'b0;
			LoadIR = 1'b0;
			MemToReg = 3'b000;
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b00;
			ALUFct = 3'b000;
			PCWrite = 1'b1;
			PCWriteCondbeq = 1'b0;
			PCWriteCondbne = 1'b0;
			PCWriteCondbge = 1'b0;
			PCWriteCondblt = 1'b0;
			PCSource = 1'b1;
			LoadRegA = 1'b0;
			LoadRegB = 1'b0;
			LoadAOut = 1'b1;
			LoadMDR = 1'b0;
			nextState = inicio;
		end

		exc: begin
			ALUSrcA = 2'b00;
			ALUSrcB = 2'b01;
			ALUFct = 3'b010;
			PCSource = 1'b0;
			PCWrite = 1'b1;
			muxInstr = 1'b1;
			LoadIR = 1'b1;
			nextState = exc2;
		end

		exc2: begin
			PCWrite = 1'b0;
			flagCausa = 1'b1;
			causa = 1'b0;
			nextState = exc3;
		end

		exc3: begin
			ALUSrcA = 2'b10;
			ALUFct = 3'b000;
			PCSource = 1'b0;
			PCWrite = 1'b1;
			flagCausa = 1'b0;
			nextState = Break;
		end
		
		Break: begin
			PCWrite = 1'b0;
			nextState = Break;
		end

		default: begin
			nextState = inicio;
		end
	endcase
end
endmodule: UnidadeControle
