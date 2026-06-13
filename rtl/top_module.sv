`timescale 1ps/1ps

module top_module (
    timer_if.dut_mp tif
);

    logic       load;
    logic       up_down;
    logic       enable;
    logic [1:0] clk_sel;
    logic       clk_ena;
    logic       overflow;
    logic       underflow;
    logic [7:0] start_counter;

    apb_controller u_apb_controller (
        .clk           (tif.clk),
        .rst_n         (tif.rst_n),
        .psel          (tif.psel),
        .penable       (tif.penable),
        .pwrite        (tif.pwrite),
        .paddr         (tif.paddr),
        .pwdata        (tif.pwdata),
        .prdata        (tif.prdata),
        .pready        (tif.pready),
        .pslverr       (tif.pslverr),
        .start_counter (start_counter),
        .load          (load),
        .up_down       (up_down),
        .enable        (enable),
        .clk_sel       (clk_sel),
        .overflow      (overflow),
        .underflow     (underflow)
    );

    clock_selection u_clock_selection (
        .clk     (tif.clk),
        .rst_n   (tif.rst_n),
        .clk_sel (clk_sel),
        .clk_in  (tif.clk_in),
        .clk_ena (clk_ena)
    );

    counter u_counter (
        .clk           (tif.clk),
        .rst_n         (tif.rst_n),
        .enable        (enable),
        .up_down       (up_down),
        .load          (load),
        .clk_ena       (clk_ena),
        .start_counter (start_counter),
        .overflow      (overflow),
        .underflow     (underflow)
    );

endmodule