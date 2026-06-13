class tcr_test extends base_test;
    rand bit [7:0] tcr_data;
         bit [7:0] data_list[20];
         bit       used_idx[20];

    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    task gen_tcr_data_list();		// create datalist with the number of appearances of 1011_0011 at least 5 times
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
            data_list[idx] = 8'hB3;
        end
    endtask

    virtual task main_run();
        int i;
        int count;

        print_test_header("tcr_test");

        print_test_section("DEFAULT REGISTER CHECK");
        print_test_step("Read TDR/TCR/TSR after reset and expect default value 0x00");
        check_reg_default_values();

        print_test_section("RANDOM TCR WRITING AND COMPARE WITH 1011_0011 = h'B3 TEST");
        gen_tcr_data_list();
        count = 0;

        for (i = 0; i < 20; i = i + 1) begin
            tcr_data = data_list[i];

            if (tcr_data == 8'hB3) begin
                count = count + 1;
                $display("[tcr_test] Hit target value 1011_0011 at [%0d]", i);
            end
            $display("[tcr_test][RANDOM][%0d] write/read TCR value=0x%02h", i, tcr_data);
            phase1_tcr_rw_once(tcr_data);
        end

 //       if (count == 5) begin
 //           $display("[tcr_test] 8'hB3 appeared %0d times", count);
 //       end

        print_test_done("tcr_test");
    endtask
endclass
