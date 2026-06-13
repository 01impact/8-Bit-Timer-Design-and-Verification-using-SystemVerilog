`timescale 1ns/1ps

module tb_apb_assertion (apb_if.tb bus);

  initial begin
    $dumpfile("apb_assertion.vcd");
    $dumpvars(0, tb_apb_assertion);
  end

  initial begin
    $timeformat(-9, 1, " ns", 9);
    $monitor("[%0t] PSEL=%0b PENABLE=%0b PWRITE=%0b PADDR=0x%08h PWDATA=0x%08h PREADY=%0b PSLVERR=%0b",
             $time, bus.PSEL, bus.PENABLE, bus.PWRITE, bus.PADDR, bus.PWDATA, bus.PREADY, bus.PSLVERR);
  end

  task automatic apb_init;
    begin
      bus.PSEL    = 1'b0;
      bus.PENABLE = 1'b0;
      bus.PWRITE  = 1'b0;
      bus.PADDR   = '0;
      bus.PWDATA  = '0;
    end
  endtask

  task automatic apb_write(input logic [31:0] addr, input logic [31:0] data);
    begin
      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b1;
      bus.PENABLE <= 1'b0;
      bus.PWRITE  <= 1'b1;
      bus.PADDR   <= addr;
      bus.PWDATA  <= data;

      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b1;
      bus.PENABLE <= 1'b1;

      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b0;
      bus.PENABLE <= 1'b0;
      bus.PWRITE  <= 1'b0;
      bus.PADDR   <= '0;
      bus.PWDATA  <= '0;
    end
  endtask

  task automatic apb_read(input logic [31:0] addr);
    begin
      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b1;
      bus.PENABLE <= 1'b0;
      bus.PWRITE  <= 1'b0;
      bus.PADDR   <= addr;

      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b1;
      bus.PENABLE <= 1'b1;

      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b0;
      bus.PENABLE <= 1'b0;
      bus.PADDR   <= '0;
    end
  endtask

  task automatic apb_invalid_enable_without_setup;
    begin
      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b1;
      bus.PENABLE <= 1'b1;
      bus.PWRITE  <= 1'b1;
      bus.PADDR   <= 32'h0000_0001;
      bus.PWDATA  <= 32'hDEAD_BEEF;

      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b0;
      bus.PENABLE <= 1'b0;
      bus.PWRITE  <= 1'b0;
      bus.PADDR   <= '0;
      bus.PWDATA  <= '0;
    end
  endtask

  initial begin
    apb_init();

    wait(bus.PRESETn == 1'b1);
    repeat (2) @(posedge bus.PCLK);

    apb_write(32'h0000_0000, 32'h1234_5678);
    repeat (2) @(posedge bus.PCLK);

    apb_read(32'h0000_0001);
    repeat (2) @(posedge bus.PCLK);

    apb_invalid_enable_without_setup();
    repeat (3) @(posedge bus.PCLK);

    $finish;
  end

endmodule