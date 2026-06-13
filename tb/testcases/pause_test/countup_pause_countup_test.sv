class countup_pause_countup_test extends base_test;
    bit [7:0] start_value;
    int i;

    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    virtual task main_run();
        print_test_header("countup_pause_countup_test");
        print_test_section("COUNT UP PAUSE THEN COUNT UP PCLK2");

	for (i = 0; i < 5; i = i + 1) begin
		random_start_value(start_value);
        	pause_countup_to_overflow(      start_value,        		// start_value
    						2'd0,               		// clk_sel
    						8'hB0,              		// load_tcr: load=1, up=1, en=1, clk0
    						8'h30,              		// run_tcr : load=0, up=1, en=1, clk0
						8'h00,		    		// pause_tcr: load=0, up=0, en=0, clk0
    						"countup_pause_countup_test"
		);
	end

        print_test_done("countup_pause_countup_test");
    endtask
endclass