`timescale 1ns/1ps

module tb_apb_assertion (apb_if.tb bus);

  `define PERIOD 10

  // Wave dump
  
  initial begin
    $dumpfile("waves/apb_assertion.vcd");
    $dumpvars(0, tb_apb_assertion);
  end

  // monitor
  initial begin
  $timeformat(-9, 1, " ns", 9);
  $monitor("[%0t] PSEL=%0b PENABLE=%0b PWRITE=%0b PADDR=0x%08h PWDATA=0x%08h PREADY=%0b PSLVERR=%0b",
               $time,
               bus.PSEL,
               bus.PENABLE,
               bus.PWRITE,
               bus.PADDR,
               bus.PWDATA,
               bus.PREADY,
               bus.PSLVERR);
  #(`PERIOD * 200) begin
    $display("APB PROTOCOL TEST TIME-OUT TT__TT!!!");
    $finish;
  end
end

  // Task: initialize APB bus to idle

  task automatic apb_init();
    begin
      bus.PSEL    = 1'b0;
      bus.PENABLE = 1'b0;
      bus.PWRITE  = 1'b0;
      bus.PADDR   = '0;
      bus.PWDATA  = '0;
      bus.PRDATA  = '0;
      bus.PREADY  = 1'b1;
      bus.PSLVERR = 1'b0;
    end
  endtask

  
  // Task: APB write transaction
  // IDLE -> SETUP -> ACCESS -> IDLE
  
  task automatic apb_write_ok(input logic [31:0] addr,
                              input logic [31:0] data);
    begin
      $display("\n[%0t] START apb_write_ok()", $time);

      // SETUP
      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b1;
      bus.PENABLE <= 1'b0;
      bus.PWRITE  <= 1'b1;
      bus.PADDR   <= addr;
      bus.PWDATA  <= data;
      bus.PREADY  <= 1'b1;
      bus.PSLVERR <= 1'b0;

      // ACCESS
      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b1;
      bus.PENABLE <= 1'b1;

      // COMPLETE -> back to IDLE
      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b0;
      bus.PENABLE <= 1'b0;
      bus.PWRITE  <= 1'b0;
      bus.PADDR   <= '0;
      bus.PWDATA  <= '0;

      $display("[%0t] END apb_write_ok()\n", $time);
    end
  endtask

  
  // Task: APB read transaction 
  // IDLE -> SETUP -> ACCESS -> IDLE
  
  task automatic apb_read_ok(input logic [31:0] addr,
                             input logic [31:0] rdata);
    begin
      $display("\n[%0t] START apb_read_ok()", $time);

      // SETUP
      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b1;
      bus.PENABLE <= 1'b0;
      bus.PWRITE  <= 1'b0;
      bus.PADDR   <= addr;
      bus.PRDATA  <= rdata;
      bus.PREADY  <= 1'b1;
      bus.PSLVERR <= 1'b0;

      // ACCESS
      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b1;
      bus.PENABLE <= 1'b1;

      // COMPLETE -> back to IDLE
      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b0;
      bus.PENABLE <= 1'b0;
      bus.PADDR   <= '0;
      bus.PRDATA  <= '0;

      $display("[%0t] END apb_read_ok()\n", $time);
    end
  endtask

  // ------------------------------------------------------------------
  // Task: APB invalid transaction
  // Illegal: directly assert PENABLE without prior setup
  // This should trigger:
  // A_APB_ENABLE_ONLY_AFTER_SETUP
  // ------------------------------------------------------------------
  task automatic apb_invalid_enable_without_setup();
    begin
      $display("\n[%0t] START apb_invalid_enable_without_setup()", $time);

      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b1;
      bus.PENABLE <= 1'b1;  // ERROR: no setup phase before this
      bus.PWRITE  <= 1'b1;
      bus.PADDR   <= 32'h0000_2000;
      bus.PWDATA  <= 32'hDEAD_BEEF;
      bus.PREADY  <= 1'b1;
      bus.PSLVERR <= 1'b0;

      @(posedge bus.PCLK);
      bus.PSEL    <= 1'b0;
      bus.PENABLE <= 1'b0;
      bus.PWRITE  <= 1'b0;
      bus.PADDR   <= '0;
      bus.PWDATA  <= '0;

      $display("[%0t] END apb_invalid_enable_without_setup()\n", $time);
    end
  endtask

  // ------------------------------------------------------------------
  // Main stimulus
  // ------------------------------------------------------------------
  initial begin
    apb_init();

    wait(bus.PRESETn == 1'b1);
    repeat (2) @(posedge bus.PCLK);

    // Case 1: valid write -> should PASS
    apb_write_ok(32'h0000_1000, 32'h1234_5678);
    repeat (2) @(posedge bus.PCLK);

    // Case 2: valid read -> should PASS
    apb_read_ok(32'h0000_1004, 32'hABCD_EF01);
    repeat (2) @(posedge bus.PCLK);

    // Case 3: invalid transaction -> should FAIL assertion
    apb_invalid_enable_without_setup();
    repeat (3) @(posedge bus.PCLK);

    $display("\n[%0t] Simulation finished.\n", $time);
    $finish;
  end

endmodule