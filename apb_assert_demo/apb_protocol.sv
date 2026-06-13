module apb_protocol (apb_if.dut bus);

  logic [7:0] reg_tcr, reg_tdr, reg_tsr;

  always @(posedge bus.PCLK or negedge bus.PRESETn) begin
    if (!bus.PRESETn) begin
      reg_tcr     <= 8'h00;
      reg_tdr     <= 8'h00;
      reg_tsr     <= 8'h00;
      bus.PRDATA  <= 8'h00;
      bus.PREADY  <= 1'b0;
      bus.PSLVERR <= 1'b0;
    end else begin
      bus.PREADY  <= 1'b0;
      bus.PSLVERR <= 1'b0;

      if (bus.PSEL && bus.PENABLE) begin
        bus.PREADY <= 1'b1;

        if (bus.PADDR > 32'h0000_0002) begin
          bus.PSLVERR <= 1'b1;
        end else if (bus.PWRITE) begin
          case (bus.PADDR[7:0])
            8'h00: reg_tcr <= bus.PWDATA[7:0];
            8'h01: reg_tdr <= bus.PWDATA[7:0];
            8'h02: reg_tsr <= bus.PWDATA[7:0];
            default: bus.PSLVERR <= 1'b1;
          endcase
        end else begin
          case (bus.PADDR[7:0])
            8'h00: bus.PRDATA <= {24'h0, reg_tcr};
            8'h01: bus.PRDATA <= {24'h0, reg_tdr};
            8'h02: bus.PRDATA <= {24'h0, reg_tsr};
            default: bus.PSLVERR <= 1'b1;
          endcase
        end
      end
    end
  end

endmodule
