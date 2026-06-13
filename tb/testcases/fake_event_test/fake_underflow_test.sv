class fake_underflow_test extends base_test;
    function new(virtual timer_if.tb_mp vif);
        super.new(vif);
    endfunction

    virtual task main_run();
        print_test_header("fake_underflow_test");
        print_test_section("FAKE UNDERFLOW TEST");

        write_reg(TCR_ADDR, 8'h00);
        write_reg(TSR_ADDR, TSR_UDF_MASK);

        print_test_step("Load 0x00 in count-down mode while EN=0");

        load_counter(	8'h00,
            		8'h80,  // load=1, up_down=0, enable=0, clk_sel=0
            		8'h00   // load=0, up_down=0, enable=0, clk_sel=0
        );

        expect_no_fake_event(	2'd0,
				TSR_UDF_MASK,
				"fake_underflow_test after disabled load 0x00"
        );

        print_test_step("Load 0xFF in count-down mode while EN=0");
        load_counter(	8'hFF,  
            		8'h80,  // load=1, up_down=0, enable=0, clk_sel=0
            		8'h00   // load=0, up_down=0, enable=0, clk_sel=0
        );

        expect_no_fake_event(	2'd0,
				TSR_UDF_MASK,
				"fake_underflow_test after disabled load 0xFF"
        );

        print_test_done("fake_underflow_test");
    endtask
endclass
