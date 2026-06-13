module apb_protocol (apb_if.dut bus);

	localparam	logic	IDLE = 2'b00;
	localparam	logic	SETUP = 2'b01;
	localparam	logic	ACCESS = 2'b10;

	logic [2:0] cur_state;
	logic [2:0] next_state;
	
	// internal register
	logic [7:0] reg_tcr, reg_tdr, reg_tsr;

	
	always @ (posedge bus.PCLK or negedge bus.PRESETn) begin
		if (!bus.PRESETn) begin 
			cur_state <= IDLE;
		end else begin
			cur_state <= next_state;
		end
	end

	always @(*) begin
		case (cur_state)
			IDLE: begin
				if (bus.PSEL & !bus.PENABLE) begin
					next_state = SETUP;
				end else begin
					next_state = IDLE;
				end
			end
			
			SETUP: begin
				if (bus.PSEL & bus.PENABLE) begin
					next_state = ACCESS;
				end else begin
					next_state = SETUP;
				end
			end 

			ACCESS: begin
                                next_state = IDLE;
                        end

			default: begin
				next_state = IDLE;
			end

		endcase
	end
	
	always @(posedge bus.PCLK or negedge bus.PRESETn) begin 
		//reset 
		if (!bus.PRESETn) begin
			reg_tcr <= 8'h00;
			reg_tdr <= 8'h00;
			reg_tsr <= 8'h00;
			bus.PSLVERR <= 1'b0;
			bus.PRDATA  <= 8'h00;
			bus.PREADY  <= 1'b0;
		end else begin
			bus.PREADY   <= 1'b0;
			bus.PSLVERR  <= 1'b0;

			if ((cur_state == ACCESS) & bus.PSEL & bus.PENABLE) begin
				bus.PREADY <= 1'b1;

				if (bus.PADDR > 8'h07) begin
					bus.PSLVERR <= 1'b1;
				end else begin
					if (bus.PWRITE) begin
						// WRITE transaction
						case (bus.PADDR)
							8'h00: reg_tcr <= bus.PWDATA;
							8'h01: reg_tdr <= bus.PWDATA;
							8'h02: reg_tsr <= bus.PWDATA;
							default: bus.PSLVERR <= 1'b1;
						endcase
					end else begin
						// READ transaction
						case (bus.PADDR)
							8'h00: bus.PRDATA <= reg_tcr;
							8'h01: bus.PRDATA <= reg_tdr;
							8'h02: bus.PRDATA <= reg_tsr;
							default: bus.PSLVERR <= 1'b1;
						endcase
					end
				end
			end
		end
	end

endmodule	

