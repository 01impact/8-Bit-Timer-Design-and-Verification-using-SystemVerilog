class tdr_test extends base_test;
    rand bit [7:0] tdr_data;

    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    virtual task main_run();
        int i;

        print_test_header("tdr_test");

        print_test_section("DEFAULT REGISTER CHECK");
        print_test_step("Read TDR/TCR/TSR after reset and expect default value 0x00");
        check_reg_default_values();

        print_test_section("RANDOM TDR WRITE/READBACK TEST");
        for (i = 0; i < 20; i = i + 1) begin
            if (!std::randomize(tdr_data)) begin
                $error("[tdr_test] Failed to randomize TDR data at [%0d]", i);
            end

            	$display("[tdr_test][RANDOM][%0d] write/read TDR value=0x%02h", i, tdr_data);
            phase1_tdr_rw_once(tdr_data);
        end

        print_test_done("tdr_test");
    endtask
endclass
