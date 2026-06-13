class countdw_reset_load_countdw_pclk2_test extends base_test;
    bit [7:0] pre_reset_value;
    bit [7:0] post_reset_value;
    int i;

    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    virtual task main_run();
        print_test_header("countdw_reset_load_countdw_pclk2_test");
        print_test_section("COUNT DOWN RESET LOAD COUNT DOWN PCLK2");

        for (i = 0; i < 5; i = i + 1) begin
            random_start_value(pre_reset_value);
            random_start_value(post_reset_value);

            reset_countdw_then_countdw(	pre_reset_value,
                			post_reset_value,
                			2'd0,
                			8'h90,
                			8'h10,
                			"countdw_reset_load_countdw_pclk2_test"
            );
        end

        print_test_done("countdw_reset_load_countdw_pclk2_test");
    endtask
endclass
