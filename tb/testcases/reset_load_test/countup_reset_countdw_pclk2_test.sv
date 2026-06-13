class countup_reset_countdw_pclk2_test extends base_test;
    bit [7:0] start_value;
    int i;

    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    virtual task main_run();
        print_test_header("countup_reset_countdw_pclk2_test");
        print_test_section("COUNT UP RESET COUNT DOWN PCLK2");

        for (i = 0; i < 5; i = i + 1) begin
            random_start_value(start_value);

            reset_countup_then_countdw(	start_value,
                			start_value,
                			2'd0,
                			8'hB0,
                			8'h30,
                			8'h90,
                			8'h10,
                			"countup_reset_countdw_pclk2_test"
            );
        end

        print_test_done("countup_reset_countdw_pclk2_test");
    endtask
endclass
