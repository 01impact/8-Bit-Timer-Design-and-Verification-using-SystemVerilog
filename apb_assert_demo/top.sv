`timescale 1ns/1ps

module top;

  logic PCLK;
  logic PRESETn;

  initial PCLK = 1'b0;
  always #5 PCLK = ~PCLK;

  initial begin
    PRESETn = 1'b0;
    #20;
    PRESETn = 1'b1;
  end

  apb_if bus(
    .PCLK(PCLK),
    .PRESETn(PRESETn)
  );

  apb_protocol      u_dut  (.bus(bus));
  tb_apb_assertion  u_test (.bus(bus));

  initial begin
    #1000;
    $finish;
  end

endmodule