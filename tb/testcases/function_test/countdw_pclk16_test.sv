class countdw_pclk16_test extends base_test;
    bit [7:0] start_value;
    int i;

    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    virtual task main_run();
        print_test_header("countdw_forkjoin_pclk16_test");
        print_test_section("COUNT DOWN FORK-JOIN PCLK16");

	for (i = 0; i < 5; i = i + 1) begin
		random_start_value(start_value);
        	forkjoin_countdw_to_underflow(  start_value,        // start_value
    						2'd3,               // clk_sel
    						8'h93,              // load_tcr: load=1, dw=0, en=1, clk3
    						8'h13,              // run_tcr : load=0, dw=0, en=1, clk3
    						"countdw_pclk16_test"
		);
	end

        print_test_done("countdw_forkjoin_pclk16_test");
    endtask
endclass