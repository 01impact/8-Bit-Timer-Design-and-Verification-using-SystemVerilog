`timescale 1ns/1ps

module top;
  logic PCLK, PRESETn;
  always #5 PCLK = ~PCLK;

  apb_if bus(PCLK, PRESETn);     // tạo interface instance, truyền clk vào

  apb_protocol      	u_apb  (.bus(bus));   // DUT
  tb_apb_assertion	u_test (.bus(bus));   // TEST

  // Reset gen
  initial begin
    bus.PRESETn = 0;
    #20;
    bus.PRESETn = 1;
  end

  initial begin
    PCLK = 0;
    #5000 $finish;
  end
endmodule
