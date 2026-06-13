class timer_scoreboard;
    virtual timer_if.tb_mp vif;
    mailbox #(apb_transaction) mon2sb;

    localparam bit [7:0] TDR_ADDR = 8'h00;
    localparam bit [7:0] TCR_ADDR = 8'h01;
    localparam bit [7:0] TSR_ADDR = 8'h02;

    bit [7:0] reg_tdr;
    bit [7:0] reg_tcr;
    bit [7:0] reg_tsr;
    bit [7:0] exp_count;
    bit       prev_sel_clk;

    int unsigned checks;
    int unsigned errors;

    function new(
        virtual timer_if.tb_mp vif,
        mailbox #(apb_transaction) mon2sb
    );
        this.vif    = vif;
        this.mon2sb = mon2sb;
        reset_model();
    endfunction

    function void reset_model();
        reg_tdr      = 8'h00;
        reg_tcr      = 8'h00;
        reg_tsr      = 8'h00;
        exp_count    = 8'h00;
        prev_sel_clk = 1'b0;
        checks       = 0;
        errors       = 0;
    endfunction

    function bit expected_err(bit [7:0] addr);
        return (addr > TSR_ADDR);
    endfunction

    function bit [7:0] expected_read_data(bit [7:0] addr);
        case (addr)
            TDR_ADDR: return reg_tdr;
            TCR_ADDR: return reg_tcr;
            TSR_ADDR: return reg_tsr;
            default : return 8'h00;
        endcase
    endfunction

    function bit get_selected_clk(bit [3:0] clk_in, bit [1:0] clk_sel);
        case (clk_sel)
            2'd0: return clk_in[0];
            2'd1: return clk_in[1];
            2'd2: return clk_in[2];
            2'd3: return clk_in[3];
        endcase
    endfunction

    task run_model_clock();
        bit       sel_clk;
        bit       clk_ena;
        bit [7:0] next_cnt;
        bit       overflow;
        bit       underflow;

        forever begin
            @(posedge vif.clk);
            #1;

            if (!vif.rst_n) begin
                reg_tdr      = 8'h00;
                reg_tcr      = 8'h00;
                reg_tsr      = 8'h00;
                exp_count    = 8'h00;
                prev_sel_clk = 1'b0;
                continue;
            end

            sel_clk = get_selected_clk(vif.clk_in, reg_tcr[1:0]);
            clk_ena = sel_clk & ~prev_sel_clk;
            prev_sel_clk = sel_clk;

            if (reg_tcr[7]) begin
                exp_count = reg_tdr;
            end else if (reg_tcr[4] && clk_ena) begin
                next_cnt   = reg_tcr[5] ? (exp_count + 8'd1) : (exp_count - 8'd1);
                overflow   = (exp_count == 8'hFF) && (next_cnt == 8'h00);
                underflow  = (exp_count == 8'h00) && (next_cnt == 8'hFF);
                exp_count  = next_cnt;
                reg_tsr[0] = reg_tsr[0] | overflow;
                reg_tsr[1] = reg_tsr[1] | underflow;
            end
        end
    endtask

    task run_bus_checks();
        apb_transaction tr;
        bit [7:0] exp_rd;
        bit       exp_err;

        forever begin
            mon2sb.get(tr);
            exp_err = expected_err(tr.addr);

            checks++;
            if (tr.rsp_err !== exp_err) begin
                errors++;
                $error("[SB] PSLVERR mismatch addr=0x%02h exp=%0b got=%0b",
                       tr.addr, exp_err, tr.rsp_err);
            end

            if (!tr.write) begin
                exp_rd = expected_read_data(tr.addr);
                checks++;
                if (tr.rsp_data !== exp_rd) begin
                    errors++;
                    $error("[SB] PRDATA mismatch addr=0x%02h exp=0x%02h got=0x%02h",
                           tr.addr, exp_rd, tr.rsp_data);
                end
            end

            if (tr.write && !expected_err(tr.addr)) begin
                case (tr.addr)
                    TDR_ADDR: reg_tdr = tr.data;
                    TCR_ADDR: reg_tcr = tr.data;
                    TSR_ADDR: reg_tsr = reg_tsr & ~tr.data;
                    default : ;
                endcase
            end
        end
    endtask

    task run();
        fork
            run_model_clock();
            run_bus_checks();
        join_none
    endtask

    function void report();
        $display("[SB] checks=%0d errors=%0d tdr=0x%02h tcr=0x%02h tsr=0x%02h exp_count=0x%02h",
                 checks, errors, reg_tdr, reg_tcr, reg_tsr, exp_count);
    endfunction
endclass
