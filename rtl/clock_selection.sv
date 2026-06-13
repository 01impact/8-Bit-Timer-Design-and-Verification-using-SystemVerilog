`timescale 1ps/1ps

module clock_selection (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [1:0] clk_sel,
    input  logic [3:0] clk_in,
    output logic       clk_ena
);

    logic prev_clk_in;
    logic reg_clk_in;
    logic reg_clk_in_ena;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_clk_in <= 1'b0;
        end else begin
            unique case (clk_sel)
                2'd0: reg_clk_in <= clk_in[0];
                2'd1: reg_clk_in <= clk_in[1];
                2'd2: reg_clk_in <= clk_in[2];
                2'd3: reg_clk_in <= clk_in[3];
                default: reg_clk_in <= 1'b0;
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_clk_in    <= 1'b0;
            reg_clk_in_ena <= 1'b0;
        end else begin
            prev_clk_in    <= reg_clk_in;
            reg_clk_in_ena <= reg_clk_in & ~prev_clk_in;
        end
    end

    assign clk_ena = reg_clk_in_ena;

endmodule