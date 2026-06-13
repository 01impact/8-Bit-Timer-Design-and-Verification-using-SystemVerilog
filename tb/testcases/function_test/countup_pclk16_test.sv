class countup_pclk16_test extends base_test;
    bit [7:0] start_value;
    int i;
    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    virtual task main_run();
        print_test_header("countup_forkjoin_pclk16_test");
        print_test_section("COUNT UP FORK-JOIN PCLK16");

	for (i = 0; i < 5; i = i + 1) begin
		random_start_value(start_value);
        	forkjoin_countup_to_overflow(   start_value,        // start_value
    						2'd3,               // clk_sel
    						8'hB3,              // load_tcr: load=1, up=1, en=1, clk3
    						8'h33,              // run_tcr : load=0, up=1, en=1, clk3
    						"countup_pclk16_test"
		);
	end

        print_test_done("countup_forkjoin_pclk16_test");
    endtask
endclass