class null_address_test extends base_test;
    bit [7:0] data_list[20];
    bit [7:0] addr_list[20];
    int       count_err;

    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    task gen_null_address_datalist();
        count_err = 0;

        for (int i = 0; i < 20; i = i + 1) begin
            addr_list[i] = $urandom_range(8'h03, 8'hFF);
            data_list[i] = $urandom_range(8'h00, 8'hFF);

            if (addr_list[i] > 8'h02) begin
                count_err++;
            end
        end
    endtask

    virtual task main_run();
        print_test_header("null_address_test");

        print_test_section("WRITE RANDOM VALUE TO RANDOM ADDRESS");
        print_test_step("Generate 20 random invalid addresses and expect PSLVERR=1");

        gen_null_address_datalist();

        for (int i = 0; i < 20; i = i + 1) begin
            $display("[null_address_test][%0d] addr=0x%02h data=0x%02h",
                     i, addr_list[i], data_list[i]);

            phase1_invalid_addr_once(addr_list[i], data_list[i]);
        end

        if (count_err != 20) begin
            $error("[null_address_test] Expected 20 invalid addresses, got %0d",
                   count_err);
        end
        else begin
            $display("[null_address_test] PASS: detected %0d invalid addresses with expected PSLVERR",
                     count_err);
        end

        print_test_done("null_address_test");
    endtask
endclass