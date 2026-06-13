interface apb_if(input logic PCLK, PRESETn);

  logic        PSEL;
  logic        PENABLE;
  logic        PWRITE;
  logic [31:0] PADDR;
  logic [31:0] PWDATA;
  logic [31:0] PRDATA;
  logic        PREADY;
  logic        PSLVERR;

  modport dut (
    input  PCLK, PRESETn, PSEL, PENABLE, PWRITE, PADDR, PWDATA,
    output PRDATA, PREADY, PSLVERR
  );

  modport tb_apb_assertion (
    input  PCLK, PRESETn, PRDATA, PREADY, PSLVERR,
    output PSEL, PENABLE, PWRITE, PADDR, PWDATA
  );

  // Utility sequences

  sequence s_idle;
    !PSEL && !PENABLE;
  endsequence

  sequence s_setup;
    PSEL && !PENABLE;
  endsequence

  sequence s_access;
    PSEL && PENABLE;
  endsequence

 // 1) Setup phase must be followed by enable phase

  property p_setup_to_enable;
    @(posedge PCLK)
    disable iff (!PRESETn)
    s_setup |=> s_access;
  endproperty

  A_APB_SETUP_TO_ENABLE:
    assert property (p_setup_to_enable)
    else $error("APB_ASSERT: setup phase not followed by enable phase");

  // 2) PENABLE can only be asserted after a valid setup phase

  property p_enable_only_after_setup;
    @(posedge PCLK)
    disable iff (!PRESETn)
    PENABLE |-> $past(PSEL && !PENABLE);
  endproperty

  A_APB_ENABLE_ONLY_AFTER_SETUP:
    assert property (p_enable_only_after_setup)
    else $error("APB_ASSERT: PENABLE asserted without prior setup phase");

 // 3) PENABLE implies PSEL

  property p_enable_implies_select;
    @(posedge PCLK)
    disable iff (!PRESETn)
    PENABLE |-> PSEL;
  endproperty

  A_APB_ENABLE_IMPLIES_SELECT:
    assert property (p_enable_implies_select)
    else $error("APB_ASSERT: PENABLE high while PSEL low");

endinterface : apb_if
