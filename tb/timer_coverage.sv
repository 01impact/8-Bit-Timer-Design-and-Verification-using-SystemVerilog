class timer_coverage;
    mailbox #(apb_transaction) mon2cov;

    bit       sample_write;
    bit [7:0] sample_addr;
    bit [7:0] sample_data;
    bit       sample_rsp_err;

    covergroup cg_apb;
        option.per_instance = 1;

        cp_write : coverpoint sample_write;

        cp_addr : coverpoint sample_addr {
            bins tdr     = {8'h00};
            bins tcr     = {8'h01};
            bins tsr     = {8'h02};
            bins invalid = {[8'h03:8'hFF]};
        }

        cp_rsp_err : coverpoint sample_rsp_err {
            bins no_err = {0};
            bins err    = {1};
        }

        cp_tcr_load : coverpoint sample_data[7] iff (sample_write && sample_addr == 8'h01) {
            bins deasserted = {0};
            bins asserted   = {1};
        }

        cp_tcr_up_down : coverpoint sample_data[5] iff (sample_write && sample_addr == 8'h01) {
            bins down = {0};
            bins up   = {1};
        }

        cp_tcr_enable : coverpoint sample_data[4] iff (sample_write && sample_addr == 8'h01) {
            bins en_off = {0};
            bins en_on  = {1};
        }

        cp_tcr_clk_sel : coverpoint sample_data[1:0] iff (sample_write && sample_addr == 8'h01) {
            bins clk0 = {2'd0};
            bins clk1 = {2'd1};
            bins clk2 = {2'd2};
            bins clk3 = {2'd3};
        }

        x_rw_addr          : cross cp_write, cp_addr;
        x_addr_err         : cross cp_addr, cp_rsp_err;
        x_ctrl_dir_clk     : cross cp_tcr_enable, cp_tcr_up_down, cp_tcr_clk_sel;
        x_load_enable_mode : cross cp_tcr_load, cp_tcr_enable, cp_tcr_up_down;
    endgroup

    function new(mailbox #(apb_transaction) mon2cov);
        this.mon2cov = mon2cov;
        cg_apb = new();
    endfunction

    task run();
        apb_transaction tr;
        forever begin
            mon2cov.get(tr);
            sample_write   = tr.write;
            sample_addr    = tr.addr;
            sample_data    = tr.data;
            sample_rsp_err = tr.rsp_err;
            cg_apb.sample();
        end
    endtask

    function void report();
        $display("[COV] functional coverage = %0.2f%%", cg_apb.get_inst_coverage());
    endfunction
endclass
