class fake_overflow_test extends base_test;
    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    virtual task main_run();
        print_test_header("fake_overflow_test");
        print_test_section("FAKE OVERFLOW TEST");

        write_reg(TCR_ADDR, 8'h00);
        write_reg(TSR_ADDR, TSR_OVF_MASK);

        print_test_step("Load 0xFF in count-up mode while EN=0");

        load_counter(	8'hFF,
            		8'hA0,  // load=1, up_down=1, enable=0, clk_sel=0
            		8'h20   // load=0, up_down=1, enable=0, clk_sel=0
        );

        expect_no_fake_event(	2'd0,
            			TSR_OVF_MASK,
            			"fake_overflow_test after disabled load 0xFF"
        );

        print_test_step("Load 0x00 in count-up mode while EN=0");
        load_counter(	8'h00,
            		8'hA0,  // load=1, up_down=1, enable=0, clk_sel=0
            		8'h20   // load=0, up_down=1, enable=0, clk_sel=0
        );

        expect_no_fake_event(	2'd0,
            			TSR_OVF_MASK,
            			"fake_overflow_test after disabled load 0x00"
        );

        print_test_done("fake_overflow_test");
    endtask
endclass
