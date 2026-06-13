class tsr_test extends base_test;
    rand bit [7:0] tsr_data;
         bit [7:0] data_list[20];
         bit       used_idx[20];

    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    task gen_tsr_data_list();		// create datalist with the number of appearances of 0 at least 5 times
        int i;
        int idx;

        for (i = 0; i < 20; i = i + 1) begin
            data_list[i] = $urandom_range(0, 255);
            used_idx[i]  = 1'b0;
        end

        for (i = 0; i < 5; i = i + 1) begin
            do begin
                idx = $urandom_range(0, 19);
            end while (used_idx[idx]);

            used_idx[idx]  = 1'b1;
            data_list[idx] = 0;
        end
    endtask

    virtual task main_run();
        int i;
        int count;

        print_test_header("tsr_test");

        print_test_section("DEFAULT REGISTER CHECK");
        print_test_step("Read TDR/TCR/TSR after reset and expect default value 0x00");
        check_reg_default_values();

        print_test_section("RANDOM TSR WRITING AND COMPARE WITH 0 TEST");
        gen_tsr_data_list();
        count = 0;

        for (i = 0; i < 20; i = i + 1) begin
            tsr_data = data_list[i];

            if (tsr_data == 0) begin
                count = count + 1;
                $display("[tsr_test] Hit target value 0 at [%0d]", i);
            end
            $display("[tsr_test][RANDOM][%0d] write/read TSR value=0x%02h", i, tsr_data);
            phase1_tsr_rw_once(tsr_data);
        end

        if (count == 5) begin
            $display("[tsr_test] 0 appeared %0d times", count);
        end

        print_test_done("tsr_test");
    endtask
endclass
