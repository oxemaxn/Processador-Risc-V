module ExtendSg( input logic menorSinal, input logic [31:0] in, output logic [63:0] out );

always_comb begin

	case(in[6:0])

		7'b0110011: begin //Tipo R (slt)

			if(menorSinal == 1'b1) out <= (64'b0000000000000000000000000000000000000000000000000000000000000001);
			else out <= (64'b0000000000000000000000000000000000000000000000000000000000000000);
		end

		7'b0010011: begin //addi

			out[11:0] <= in[31:20];

			if( in[31] == 1'b0 ) begin
				out[63:12] <= 52'b0000000000000000000000000000000000000000000000000000;
			end else if( in[31] == 1'b1 ) begin
				out[63:12] <= 52'b1111111111111111111111111111111111111111111111111111;
			end
		end

		7'b0000011: begin //ld

			out[11:0] <= in[31:20];
			
			if( in[31] == 1'b0 ) begin
				out[63:12] <= 52'b0000000000000000000000000000000000000000000000000000;
			end else if( in[31] == 1'b1 ) begin
				out[63:12] <= 52'b1111111111111111111111111111111111111111111111111111;
			end	
		end

		7'b0100011: begin //sd
			out[4:0] <= in[11:7];
			out[11:5] <= in[31:25];
			
			if( in[31] == 1'b0 ) begin
				out[63:12] <= 52'b0000000000000000000000000000000000000000000000000000;
			end else if( in[31] == 1'b1 ) begin
				out[63:12] <= 52'b1111111111111111111111111111111111111111111111111111;
			end	
		end

		7'b1100011: begin //beq
			out[0] = 1'b0;
			out[4:1] = in[11:8];
			out[10:5] = in[30:25];
			out[11] = in[7];
			out[12] = in[31];
			
			if( in[31] == 1'b0 ) begin
				out[63:12] <= 51'b000000000000000000000000000000000000000000000000000;
			end else if( in[31] == 1'b1 ) begin
				out[63:12] <= 51'b111111111111111111111111111111111111111111111111111;
			end	
		end

		7'b1100111: begin //bne
			out[0] = 1'b0;
			out[4:1] = in[11:8];
			out[10:5] = in[30:25];
			out[11] = in[7];
			out[12] = in[31];

			if( in[31] == 1'b0 ) begin
				out[63:12] <= 51'b000000000000000000000000000000000000000000000000000;
			end else if( in[31] == 1'b1 ) begin
				out[63:12] <= 51'b111111111111111111111111111111111111111111111111111;
			end	
		end
		7'b0110111: begin //lui
			out[11:0] = 12'b000000000000;
			out[31:12] = in[31:12];

			if( in[31] == 1'b0 ) begin
				out[63:32] <= 32'b00000000000000000000000000000000;
			end else if( in[31] == 1'b1 ) begin
				out[63:32] <= 32'b11111111111111111111111111111111;
			end	
		end
		default: begin
			out[63:0] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
		end
	endcase
end

endmodule: ExtendSg
