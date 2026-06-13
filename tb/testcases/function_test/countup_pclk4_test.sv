class countup_pclk4_test extends base_test;
    bit [7:0] start_value;
    int i;

    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    virtual task main_run();
        print_test_header("countup_forkjoin_pclk4_test");
        print_test_section("COUNT UP FORK-JOIN PCLK4");

	for (i = 0; i < 5; i = i + 1) begin
		random_start_value(start_value);
        	forkjoin_countup_to_overflow(   start_value,        // start_value
    						2'd1,               // clk_sel
    						8'hB1,              // load_tcr: load=1, up=1, en=1, clk1
    						8'h31,              // run_tcr : load=0, up=1, en=1, clk1
    						"countup_pclk4_test"
		);
	end

        print_test_done("countup_forkjoin_pclk4_test");
    endtask
endclass