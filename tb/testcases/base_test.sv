class base_test;
    virtual timer_if.tb_mp vif;
    timer_environment env;

    localparam bit [7:0] TDR_ADDR = 8'h00;
    localparam bit [7:0] TCR_ADDR = 8'h01;
    localparam bit [7:0] TSR_ADDR = 8'h02;
    localparam bit [7:0] TSR_OVF_MASK = 8'h01;
    localparam bit [7:0] TSR_UDF_MASK = 8'h02;
    localparam int unsigned COUNT_PAUSE = 8;
    localparam int unsigned FAKE_EVENT_WAIT = 8;

    function new(virtual timer_if.tb_mp vif);
        this.vif = vif;
    endfunction

    virtual function void build();
        env = new(vif);
        env.build();
    endfunction

    virtual task start_env();
        env.start();
    endtask

    virtual task wait_for_reset_release();
        wait (vif.rst_n === 1'b1);
        repeat (2) @(posedge vif.clk);
    endtask

    virtual task write_reg(input bit [7:0] addr, input bit [7:0] data);
        env.stim.send_write(addr, data);
        env.wait_idle();
    endtask

    virtual task read_reg(input bit [7:0] addr);
        env.stim.send_read(addr);
        env.wait_idle();
    endtask

    virtual task wait_for_env_idle();
        env.wait_idle();
    endtask

  // ---------------- Test user interface ----------------------------

    virtual task print_test_header(input string test_name);
        $display("");
        $display("============================================================");
        $display("[TEST][START] %s", test_name);
        $display("============================================================");
    endtask

    virtual task print_test_section(input string section_name);
        $display("");
        $display("------------------------------------------------------------");
        $display("[TEST][SECTION] %s", section_name);
        $display("------------------------------------------------------------");
    endtask

    virtual task print_test_step(input string msg);
        $display("[TEST][STEP] %s", msg);
    endtask

    virtual task print_test_done(input string test_name);
        $display("============================================================");
        $display("[TEST][DONE] %s", test_name);
        $display("============================================================");
        $display("");
    endtask

  // ---------------- Apb helper for test ----------------------------

    virtual function int unsigned get_error_count();
        return env.sb.errors;
    endfunction

    virtual task expect_no_new_errors(
        input int unsigned prev_errors,
        input string       msg
    );
        env.wait_idle();
        if (env.sb.errors != prev_errors) begin
            $error("[TEST] %s: scoreboard errors changed from %0d to %0d",
                   msg, prev_errors, env.sb.errors);
        end
    endtask

    virtual task write_then_readback(
        input bit [7:0] addr,
        input bit [7:0] data,
        input string    msg
    );
        int unsigned prev_errors;

        prev_errors = get_error_count();
        env.stim.send_write(addr, data);
        env.stim.send_read(addr);
        expect_no_new_errors(prev_errors, msg);
    endtask

    virtual task check_reg_default_values();
        read_reg(TDR_ADDR);
        read_reg(TCR_ADDR);
        read_reg(TSR_ADDR);
    endtask

  // ---------------- phase 1 test helper ----------------------------

    virtual task phase1_tdr_rw_once(input bit [7:0] value);
        write_then_readback(TDR_ADDR, value, "phase1_tdr_rw_once");
    endtask

    virtual task phase1_tcr_rw_once(input bit [7:0] value);
        write_then_readback(TCR_ADDR, value, "phase1_tcr_rw_once");
    endtask

    virtual task phase1_tsr_rw_once(input bit [7:0] value);
        write_then_readback(TSR_ADDR, value, "phase1_tsr_rw_once");
    endtask

    virtual task phase1_tsr_clear_once(input bit [7:0] value);
        int unsigned prev_errors;

        prev_errors = get_error_count();
        env.stim.send_write(TSR_ADDR, value);
        env.stim.send_read(TSR_ADDR);
        expect_no_new_errors(prev_errors, "phase1_tsr_clear_once");
    endtask

    virtual task phase1_invalid_addr_once(
        input bit [7:0] addr,
        input bit [7:0] data
    );
        int unsigned prev_errors;

        prev_errors = get_error_count();
        env.stim.send_write(addr, data);
        env.stim.send_read(addr);
        expect_no_new_errors(prev_errors, "phase1_invalid_addr_once");
    endtask

    virtual task check_no_status(input string msg);
        env.wait_idle();
        if (env.sb.reg_tsr !== 8'h00) begin
            $error("[TEST] %s: expected TSR=0x00, got 0x%02h",
                   msg, env.sb.reg_tsr);
        end
    endtask

  // ---------------- phase 2 test helper ----------------------------

    virtual task wait_selected_clk_edges(
        input bit [1:0] clk_sel,
        input int unsigned num_edges
    );
        int unsigned edge_count;
        bit prev_clk;
        bit curr_clk;

        edge_count = 0;
        prev_clk = vif.clk_in[clk_sel];

        while (edge_count < num_edges) begin
            @(posedge vif.clk);
            curr_clk = vif.clk_in[clk_sel];

            if (!prev_clk && curr_clk) begin
                edge_count = edge_count + 1;
            end

            prev_clk = curr_clk;
        end

    endtask

    virtual task expect_status_bit_clear(
        input bit [7:0] mask,
        input string msg
    );
        read_reg(TSR_ADDR);

        if ((env.sb.reg_tsr & mask) != 0) begin
            $error("[BASE_TEST] %s: status bit was set too early, TSR=0x%02h",
                   msg, env.sb.reg_tsr);
        end
        else begin
            $display("[BASE_TEST] %s: status bit still clear as expected", msg);
        end
    endtask

    virtual task expect_status_bit_set(
        input bit [7:0] mask,
        input string msg
    );
        read_reg(TSR_ADDR);

        if ((env.sb.reg_tsr & mask) == 0) begin
            $error("[BASE_TEST] %s: expected status bit set, TSR=0x%02h",
                   msg, env.sb.reg_tsr);
        end
        else begin
            $display("[BASE_TEST] %s: status bit set as expected, TSR=0x%02h",
                     msg, env.sb.reg_tsr);
        end
    endtask


    virtual task load_counter(
	input bit [7:0] start_value,
	input bit [7:0] load_tcr,
	input bit [7:0] run_tcr
    );

    	write_reg(TDR_ADDR, start_value);
    	write_reg(TCR_ADDR, load_tcr);
    	write_reg(TCR_ADDR, run_tcr);
    endtask

    task random_start_value(output bit [7:0] start_value);
    if (!std::randomize(start_value) with {
        start_value inside {[8'd50:8'd200]};		// safety threshold co system to reach ovf/udf flag that will not make status bit be setted too early
        }) begin
            $error("[BASE_TEST] Failed to randomize start_value");
        end

        $display("[BASE_TEST] Random start_value = 0x%02h (%0d)",
                 start_value, start_value);
    endtask


    virtual task forkjoin_countup_to_overflow(
        input bit [7:0] start_value,
        input bit [1:0] clk_sel,
	input bit [7:0] load_tcr,
	input bit [7:0] run_tcr,
        input string    test_name
    );
        int unsigned full_edges;
        int unsigned early_edges;

        full_edges  = 256 - start_value;
        early_edges = (full_edges * 2) / 3;

        if (early_edges == 0)
            early_edges = 1;

	write_reg(TCR_ADDR, 8'h00);        	// stop letting the timer continue running from the previous time.
	write_reg(TSR_ADDR,8'h01);              // clear OVF sticky flag
        load_counter(start_value, load_tcr, run_tcr);

        fork
            begin
                wait_selected_clk_edges(clk_sel, full_edges);
                expect_status_bit_set(TSR_OVF_MASK, {test_name, " full overflow check"});
            end

            begin
                wait_selected_clk_edges(clk_sel, early_edges);
                expect_status_bit_clear(TSR_OVF_MASK, {test_name, " early overflow check"});
            end
        join
    endtask

    virtual task forkjoin_countdw_to_underflow(
	input bit [7:0] start_value,
        input bit [1:0] clk_sel,
	input bit [7:0] load_tcr,
	input bit [7:0] run_tcr,
        input string    test_name
    );
	int unsigned full_edges;
        int unsigned early_edges;

	full_edges = start_value;
	early_edges = (full_edges * 2) / 3;
	
	if (early_edges == 0)
        early_edges = 1;
	
	write_reg(TCR_ADDR, 8'h00);        	// stop letting the timer continue running from the previous time.
	write_reg(TSR_ADDR,8'h02);              // clear UDF sticky flag
	load_counter(start_value, load_tcr, run_tcr);
    
        fork
            begin
                wait_selected_clk_edges(clk_sel, full_edges);
                expect_status_bit_set(TSR_UDF_MASK, {test_name, " full underflow check"});
            end

            begin
                wait_selected_clk_edges(clk_sel, early_edges);
                expect_status_bit_clear(TSR_UDF_MASK, {test_name, " early underflow check"});
            end
        join

    endtask

  // ---------------- phase 3 test helper ----------------------------

    virtual task pause_countup_to_overflow(
        input bit [7:0] start_value,
        input bit [1:0] clk_sel,
        input bit [7:0] load_tcr,
        input bit [7:0] run_tcr,
        input bit [7:0] pause_tcr,
        input string    test_name
    );
        int unsigned full_edges;
        int unsigned pre_pause_edges;
        int unsigned remain_edges;

        full_edges      = 256 - start_value;
        pre_pause_edges = full_edges / 3;

        if (pre_pause_edges == 0)
            pre_pause_edges = 1;

        if (pre_pause_edges >= full_edges)
            pre_pause_edges = full_edges - 1;

        remain_edges = full_edges - pre_pause_edges;

        write_reg(TCR_ADDR, 8'h00);
        write_reg(TSR_ADDR, TSR_OVF_MASK);
        load_counter(start_value, load_tcr, run_tcr);

        wait_selected_clk_edges(clk_sel, pre_pause_edges);
        write_reg(TCR_ADDR, pause_tcr);

        wait_selected_clk_edges(clk_sel, COUNT_PAUSE);
        expect_status_bit_clear(TSR_OVF_MASK, {test_name, " pause overflow check"});

        write_reg(TCR_ADDR, run_tcr);
        wait_selected_clk_edges(clk_sel, remain_edges);
        expect_status_bit_set(TSR_OVF_MASK, {test_name, " resume overflow check"});
    endtask

    virtual task pause_countdw_to_underflow(
        input bit [7:0] start_value,
        input bit [1:0] clk_sel,
        input bit [7:0] load_tcr,
        input bit [7:0] run_tcr,
        input bit [7:0] pause_tcr,
        input string    test_name
    );
        int unsigned full_edges;
        int unsigned pre_pause_edges;
        int unsigned remain_edges;

        full_edges      = start_value + 1;
        pre_pause_edges = full_edges / 3;

        if (pre_pause_edges == 0)
            pre_pause_edges = 1;

        if (pre_pause_edges >= full_edges)
            pre_pause_edges = full_edges - 1;

        remain_edges = full_edges - pre_pause_edges;

        write_reg(TCR_ADDR, 8'h00);
        write_reg(TSR_ADDR, TSR_UDF_MASK);
        load_counter(start_value, load_tcr, run_tcr);

        wait_selected_clk_edges(clk_sel, pre_pause_edges);
        write_reg(TCR_ADDR, pause_tcr);

        wait_selected_clk_edges(clk_sel, COUNT_PAUSE);
        expect_status_bit_clear(TSR_UDF_MASK, {test_name, " pause underflow check"});

        write_reg(TCR_ADDR, run_tcr);
        wait_selected_clk_edges(clk_sel, remain_edges);
        expect_status_bit_set(TSR_UDF_MASK, {test_name, " resume underflow check"});
    endtask

  // ---------------- phase 4 test helper ----------------------------

    virtual function int unsigned get_safe_pre_reset_edges(input int unsigned full_edges);
        int unsigned pre_reset_edges;

        pre_reset_edges = full_edges / 3;

        if (pre_reset_edges == 0)
            pre_reset_edges = 1;

        if (pre_reset_edges >= full_edges)
            pre_reset_edges = full_edges - 1;

        return pre_reset_edges;
    endfunction

    virtual task apply_mid_reset(input string msg);
        $display("[BASE_TEST] %s: apply mid-test reset", msg);

        @(posedge vif.clk);
        vif.init_master();
        vif.rst_n <= 1'b0;

        repeat (5) @(posedge vif.clk);
        vif.rst_n <= 1'b1;

        repeat (2) @(posedge vif.clk);
    endtask

    virtual task check_reset_default_regs(input string msg);
        int unsigned prev_errors;

        prev_errors = get_error_count();

        read_reg(TDR_ADDR);
        read_reg(TCR_ADDR);
        read_reg(TSR_ADDR);

        if (env.sb.errors == prev_errors) begin
            $display("[BASE_TEST] %s: TDR/TCR/TSR reset default check passed", msg);
        end
        else begin
            $error("[BASE_TEST] %s: TDR/TCR/TSR reset default check failed", msg);
        end
    endtask

    virtual task reset_countup_then_countdw(
        input bit [7:0] pre_reset_value,
        input bit [7:0] post_reset_value,
        input bit [1:0] clk_sel,
        input bit [7:0] countup_load_tcr,
        input bit [7:0] countup_run_tcr,
        input bit [7:0] countdw_load_tcr,
        input bit [7:0] countdw_run_tcr,
        input string    test_name
    );
        int unsigned full_edges;
        int unsigned pre_reset_edges;

        full_edges      = 256 - pre_reset_value;
        pre_reset_edges = get_safe_pre_reset_edges(full_edges);

        write_reg(TCR_ADDR, 8'h00);
        write_reg(TSR_ADDR, TSR_OVF_MASK | TSR_UDF_MASK);
        load_counter(pre_reset_value, countup_load_tcr, countup_run_tcr);

        wait_selected_clk_edges(clk_sel, pre_reset_edges);
        apply_mid_reset({test_name, " reset phase"});
        check_reset_default_regs({test_name, " reset default"});

        load_counter(post_reset_value, countdw_load_tcr, countdw_run_tcr);
        wait_selected_clk_edges(clk_sel, post_reset_value + 1);
        expect_status_bit_set(TSR_UDF_MASK, {test_name, " post-reset underflow check"});
    endtask

    virtual task reset_countdw_then_countup(
        input bit [7:0] pre_reset_value,
        input bit [7:0] post_reset_value,
        input bit [1:0] clk_sel,
        input bit [7:0] countdw_load_tcr,
        input bit [7:0] countdw_run_tcr,
        input bit [7:0] countup_load_tcr,
        input bit [7:0] countup_run_tcr,
        input string    test_name
    );
        int unsigned full_edges;
        int unsigned pre_reset_edges;

        full_edges      = pre_reset_value + 1;
        pre_reset_edges = get_safe_pre_reset_edges(full_edges);

        write_reg(TCR_ADDR, 8'h00);
        write_reg(TSR_ADDR, TSR_OVF_MASK | TSR_UDF_MASK);
        load_counter(pre_reset_value, countdw_load_tcr, countdw_run_tcr);

        wait_selected_clk_edges(clk_sel, pre_reset_edges);
        apply_mid_reset({test_name, " reset phase"});
        check_reset_default_regs({test_name, " reset default"});

        load_counter(post_reset_value, countup_load_tcr, countup_run_tcr);
        wait_selected_clk_edges(clk_sel, 256 - post_reset_value);
        expect_status_bit_set(TSR_OVF_MASK, {test_name, " post-reset overflow check"});
    endtask

    virtual task reset_countdw_then_countdw(
        input bit [7:0] pre_reset_value,
        input bit [7:0] post_reset_value,
        input bit [1:0] clk_sel,
        input bit [7:0] countdw_load_tcr,
        input bit [7:0] countdw_run_tcr,
        input string    test_name
    );
        int unsigned full_edges;
        int unsigned pre_reset_edges;

        full_edges      = pre_reset_value + 1;
        pre_reset_edges = get_safe_pre_reset_edges(full_edges);

        write_reg(TCR_ADDR, 8'h00);
        write_reg(TSR_ADDR, TSR_OVF_MASK | TSR_UDF_MASK);
        load_counter(pre_reset_value, countdw_load_tcr, countdw_run_tcr);

        wait_selected_clk_edges(clk_sel, pre_reset_edges);
        apply_mid_reset({test_name, " reset phase"});
        check_reset_default_regs({test_name, " reset default"});

        load_counter(post_reset_value, countdw_load_tcr, countdw_run_tcr);
        wait_selected_clk_edges(clk_sel, post_reset_value + 1);
        expect_status_bit_set(TSR_UDF_MASK, {test_name, " post-reset underflow check"});
    endtask

  // ---------------- phase 5 test helper ----------------------------

    virtual task expect_no_fake_event(
    	input bit [1:0] clk_sel,
    	input bit [7:0] status_mask,
    	input string    msg
    );
   	wait_selected_clk_edges(clk_sel, FAKE_EVENT_WAIT);
    	expect_status_bit_clear(status_mask, msg);
    endtask

    virtual task main_run();
    endtask

    virtual task run();
        build();
        vif.init_master();
        start_env();
        wait_for_reset_release();
        main_run();
        env.wait_idle();
        report();
    endtask

    virtual function void report();
        env.report();

        if (env.sb.errors == 0)
            $display("[TEST] PASS");
        else
            $display("[TEST] FAIL errors=%0d", env.sb.errors);
    endfunction
endclass
