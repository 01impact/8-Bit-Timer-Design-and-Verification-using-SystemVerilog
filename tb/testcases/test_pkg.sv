package test_pkg;
    import timer_pkg::*;

    `include "base_test.sv"

    `include "tdr_test.sv"
    `include "tcr_test.sv"
    `include "tsr_test.sv"
    `include "null_address_test.sv"
    `include "mixed_address_test.sv"
    `include "countup_pclk2_test.sv"
    `include "countup_pclk4_test.sv"
    `include "countup_pclk8_test.sv"
    `include "countup_pclk16_test.sv"
    `include "countdw_pclk2_test.sv"
    `include "countdw_pclk4_test.sv"
    `include "countdw_pclk8_test.sv"
    `include "countdw_pclk16_test.sv"
    `include "countup_pause_countup_test.sv"
    `include "countdw_pause_countdw_test.sv"
    `include "countup_reset_countdw_pclk2_test.sv"
    `include "countdw_reset_countup_pclk2_test.sv"
    `include "countup_reset_load_countdw_pclk2_test.sv"
    `include "countdw_reset_load_countdw_pclk2_test.sv"
    `include "fake_underflow_test.sv"
    `include "fake_overflow_test.sv"

endpackage
