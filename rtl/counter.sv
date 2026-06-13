`timescale 1ps/1ps

module counter (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       enable,         // reg_tcr[4]
    input  logic       up_down,        // reg_tcr[5]
    input  logic       load,           // reg_tcr[7]
    input  logic       clk_ena,
    input  logic [7:0] start_counter,  // reg_tdr[7:0]
    output logic       overflow,
    output logic       underflow
);

    logic [7:0] count;
    logic [7:0] inc_val;
    logic [7:0] dec_val;
    logic [7:0] next_cnt;
    logic       will_overflow;
    logic       will_underflow;

// generate 1-cycle overflow/underflow.
// Register spec and ports preserved.

    always_comb begin
        inc_val        = count + 8'd1;
        dec_val        = count - 8'd1;
        next_cnt       = up_down ? inc_val : dec_val;
        will_overflow  = (count == 8'hFF) && (next_cnt == 8'h00);
        will_underflow = (count == 8'h00) && (next_cnt == 8'hFF);
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count     <= 8'h00;
            overflow  <= 1'b0;
            underflow <= 1'b0;
        end else if (load) begin
            count     <= start_counter;
            overflow  <= 1'b0;
            underflow <= 1'b0;
        end else if (enable && clk_ena) begin
            count     <= next_cnt;
            overflow  <= will_overflow;
            underflow <= will_underflow;
        end else begin
            overflow  <= 1'b0;
            underflow <= 1'b0;
        end
    end

endmodule