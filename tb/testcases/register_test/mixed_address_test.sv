class mixed_address_test extends base_test;
    bit [7:0] addr_list[20];
    bit [7:0] data_list[20];
    int       count_err;
    bit       used_idx[20];

    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    task gen_mixed_address_datalist();
        int i;
        int j;
        int idx;

        count_err = 0;

        for (i = 0; i < 20; i = i + 1) begin
            addr_list[i] = $urandom_range(3, 255);
            data_list[i] = $urandom_range(0, 255);
            used_idx[i]  = 1'b0;
        end

// Set the randomization value three times for each apperance of a valid address during the randomization process.

        for (j = 0; j < 3; j = j + 1) begin
            do begin
                idx = $urandom_range(0, 19);
            end while (used_idx[idx]);

            used_idx[idx]  = 1'b1;
            addr_list[idx] = 8'h00;
        end

        for (j = 0; j < 3; j = j + 1) begin
            do begin
                idx = $urandom_range(0, 19);
            end while (used_idx[idx]);

            used_idx[idx]  = 1'b1;
            addr_list[idx] = 8'h01;
        end

        for (j = 0; j < 3; j = j + 1) begin
            do begin
                idx = $urandom_range(0, 19);
            end while (used_idx[idx]);

            used_idx[idx]  = 1'b1;
            addr_list[idx] = 8'h02;
        end

        for (i = 0; i < 20; i = i + 1) begin
            if (addr_list[i] > 8'h02) begin
                count_err = count_err + 1;
            end
        end
    endtask

    virtual task main_run();
        int i;

        print_test_header("mixed_address_test");

        print_test_section("MIXED VALID AND INVALID ADDRESS RANDOM TEST");
        print_test_step("Generate mixed TDR/TCR/TSR/invalid accesses and check response by address map");

        gen_mixed_address_datalist();

        for (i = 0; i < 20; i = i + 1) begin
            $display("[mixed_address_test][%0d] addr=0x%02h data=0x%02h",
                     i, addr_list[i], data_list[i]);

            case (addr_list[i])
                8'h00: begin
                    write_then_readback(8'h00, data_list[i], "mixed_address_test TDR access");
                end

                8'h01: begin
                    write_then_readback(8'h01, data_list[i], "mixed_address_test TCR access");
                end

                8'h02: begin
                    phase1_tsr_clear_once(data_list[i]);
                    check_no_status("mixed_address_test TSR remains zero without events");
                end

                default: begin
                    phase1_invalid_addr_once(addr_list[i], data_list[i]);
                end
            endcase
        end

        $display("[mixed_address_test] count_err = %0d / 20", count_err);

        if (count_err != 11) begin
            $error("[mixed_address_test] Expected 11 invalid addresses, got %0d",
                   count_err);
        end

        print_test_done("mixed_address_test");
    endtask
endclass
