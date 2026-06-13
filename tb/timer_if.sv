`timescale 1ns/1ps

interface timer_if;
    logic       clk;
    logic       rst_n;
    logic       psel;
    logic       penable;
    logic       pwrite;
    logic [7:0] paddr;
    logic [7:0] pwdata;
    logic [7:0] prdata;
    logic       pready;
    logic       pslverr;
    logic [3:0] clk_in;

    modport dut_mp (
        input  clk,
        input  rst_n,
        input  psel,
        input  penable,
        input  pwrite,
        input  paddr,
        input  pwdata,
        input  clk_in,
        output prdata,
        output pready,
        output pslverr
    );

    modport tb_mp (
        input  clk,
        input  prdata,
        input  pready,
        input  pslverr,
        output rst_n,
        output psel,
        output penable,
        output pwrite,
        output paddr,
        output pwdata,
        output clk_in,
	import init_master
    );

    task automatic init_master();
        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;
        paddr   = '0;
        pwdata  = '0;
    endtask

endinterface
