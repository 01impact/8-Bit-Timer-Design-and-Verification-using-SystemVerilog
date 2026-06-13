`timescale 1ps/1ps

module tb_top;

  string testname;  
  reg clk_in0, clk_in1, clk_in2, clk_in3;
  parameter integer TIME = 10;

  localparam integer D0 = (TIME   > 0) ? TIME   : 1;
  localparam integer D1 = (TIME*2 > 0) ? TIME*2 : 1;
  localparam integer D2 = (TIME*4 > 0) ? TIME*4 : 1;
  localparam integer D3 = (TIME*8 > 0) ? TIME*8 : 1;

  import timer_pkg::*;
  import test_pkg::*;

  timer_if tif();

  // ---------------- Define parent test and various testcases  ----------------------------

  base_test         t;
  tdr_test          tdr_t;
  tcr_test          tcr_t;
  tsr_test          tsr_t;
  null_address_test null_t;
  mixed_address_test mixed_t;
  countup_pclk2_test cntup_pclk2_t;
  countup_pclk4_test cntup_pclk4_t;
  countup_pclk8_test cntup_pclk8_t;
  countup_pclk16_test cntup_pclk16_t;
  countdw_pclk2_test cntdw_pclk2_t;
  countdw_pclk4_test cntdw_pclk4_t;
  countdw_pclk8_test cntdw_pclk8_t;
  countdw_pclk16_test cntdw_pclk16_t;
  countup_pause_countup_test cntup_pause_t;
  countdw_pause_countdw_test cntdw_pause_t;  
  countup_reset_countdw_pclk2_test cntup_rst_cntdw_t;
  countdw_reset_countup_pclk2_test cntdw_rst_cntup_t;
  countup_reset_load_countdw_pclk2_test cntup_rst_load_cntdw_t;
  countdw_reset_load_countdw_pclk2_test cntdw_rst_load_cntdw_t;
  fake_underflow_test fake_udf_t;
  fake_overflow_test fake_ovf_t;


  top_module dut (
    .tif(tif)
  );

  // ---------------- clock selection set-up  ----------------------------

  assign tif.clk_in = {clk_in3, clk_in2, clk_in1, clk_in0};

  initial begin
    tif.clk = 1'b1;
    forever #(TIME/2) tif.clk = ~tif.clk;
  end

  initial begin
    tif.rst_n = 1'b0;
    repeat (5) @(posedge tif.clk);
    tif.rst_n = 1'b1;
  end

  initial begin
    clk_in0 = 1'b1;
    forever #(D0) clk_in0 = ~clk_in0;
  end

  initial begin
    clk_in1 = 1'b1;
    forever #(D1) clk_in1 = ~clk_in1;
  end

  initial begin
    clk_in2 = 1'b1;
    forever #(D2) clk_in2 = ~clk_in2;
  end

  initial begin
    clk_in3 = 1'b1;
    forever #(D3) clk_in3 = ~clk_in3;
  end

  // ---------------- Perform test base on TESTNAME input command ----------------------------
  initial begin
    if (!$value$plusargs("TESTNAME=%s", testname))
      testname = "base_test";

    $display("[TB_TOP] Selected test = %s", testname);

    if (testname == "tdr_test") begin
      tdr_t = new(tif);
      t = tdr_t;
    end
    else if (testname == "tcr_test") begin
      tcr_t = new(tif);
      t = tcr_t;
    end
    else if (testname == "tsr_test") begin
      tsr_t = new(tif);
      t = tsr_t;
    end
    else if (testname == "null_address_test") begin
      null_t = new(tif);
      t = null_t;
    end
    else if (testname == "mixed_address_test") begin
      mixed_t = new(tif);
      t = mixed_t;
    end
    else if (testname == "countup_pclk2_test") begin
      cntup_pclk2_t = new(tif);
      t = cntup_pclk2_t;
    end
    else if (testname == "countup_pclk4_test") begin
      cntup_pclk4_t = new(tif);
      t = cntup_pclk4_t;
    end
    else if (testname == "countup_pclk8_test") begin
      cntup_pclk8_t = new(tif);
      t = cntup_pclk8_t;
    end
    else if (testname == "countup_pclk16_test") begin
      cntup_pclk16_t = new(tif);
      t = cntup_pclk16_t;
    end
    else if (testname == "countdw_pclk2_test") begin
      cntdw_pclk2_t = new(tif);
      t = cntdw_pclk2_t;
    end
    else if (testname == "countdw_pclk4_test") begin
      cntdw_pclk4_t = new(tif);
      t = cntdw_pclk4_t;
    end
    else if (testname == "countdw_pclk8_test") begin
      cntdw_pclk8_t = new(tif);
      t = cntdw_pclk8_t;
    end
    else if (testname == "countdw_pclk16_test") begin
      cntdw_pclk16_t = new(tif);
      t = cntdw_pclk16_t;
    end
    else if (testname == "countup_pause_countup_test") begin
      cntup_pause_t = new(tif);
      t = cntup_pause_t;
    end
    else if (testname == "countdw_pause_countdw_test") begin
      cntdw_pause_t = new(tif);
      t = cntdw_pause_t;
    end
    else if (testname == "countup_reset_countdw_pclk2_test") begin
      cntup_rst_cntdw_t = new(tif);
      t = cntup_rst_cntdw_t;
    end
    else if (testname == "countdw_reset_countup_pclk2_test") begin
      cntdw_rst_cntup_t = new(tif);
      t = cntdw_rst_cntup_t;
    end
    else if (testname == "countup_reset_load_countdw_pclk2_test") begin
      cntup_rst_load_cntdw_t = new(tif);
      t = cntup_rst_load_cntdw_t;
    end
    else if (testname == "countdw_reset_load_countdw_pclk2_test") begin
      cntdw_rst_load_cntdw_t = new(tif);
      t = cntdw_rst_load_cntdw_t;
    end
    else if (testname == "fake_underflow_test") begin
      fake_udf_t = new(tif);
      t = fake_udf_t;
    end
    else if (testname == "fake_overflow_test") begin
      fake_ovf_t = new(tif);
      t = fake_ovf_t;
    end

    else begin
      t = new(tif);
    end

  // ---------------- Run test ----------------------------

    t.run();
    #100;
    $finish;
  end

endmodule
