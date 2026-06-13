
module apb_controller (
    input   logic   clk,
    input   logic   rst_n,
    input   logic   psel,
    input   logic   penable,
    input   logic   pwrite,
    input   logic   [7:0] paddr,
    input   logic   [7:0] pwdata,
    output  logic   [7:0] prdata,
    output  logic   pready,
    output  logic   pslverr,
    output  logic   [7:0] start_counter,   // TDR
    output  logic   load,                  // TCR[7]
    output  logic   up_down,               // TCR[5]
    output  logic   enable,                // TCR[4]
    output  logic   [1:0] clk_sel,         // TCR[1:0]
    input   logic   overflow,
    input   logic   underflow
);

  // Address map
  localparam [7:0] TDR_ADDR = 8'h00;
  localparam [7:0] TCR_ADDR = 8'h01;
  localparam [7:0] TSR_ADDR = 8'h02;

  // APB protocol
  localparam
      IDLE   = 0,
      SETUP  = 1,
      ACCESS = 2;

  logic [1:0] state;       
  logic [1:0] next_state;  

  // Registers
  logic [7:0] reg_tdr, reg_tcr, reg_tsr;
  logic [7:0] tsr_next;    // next-state cho TSR 

  always @(*) begin
    case (state)
      IDLE:   next_state = (psel & !penable) ? SETUP  : IDLE;
      SETUP:  next_state = (psel &  penable) ? ACCESS : IDLE;
      ACCESS: next_state = IDLE;
      default:next_state = IDLE;
    endcase
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state <= IDLE;
    else
      state <= next_state;
  end

  // ---------------------------------------
  // WRITE TDR/TCR 
  // ---------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      reg_tdr <= 8'h00;
      reg_tcr <= 8'h00;
    end else if ((state == ACCESS) && pwrite) begin
      case (paddr)
        TDR_ADDR: reg_tdr <= pwdata;
        TCR_ADDR: reg_tcr <= pwdata;
        default: ; 
      endcase
    end
  end

  // ---------------------------------------
  // WRITE TSR
  // ---------------------------------------

  always @* begin
    tsr_next = reg_tsr | {6'b0, underflow, overflow};

    if ((state == ACCESS) && pwrite && (paddr == TSR_ADDR)) begin
      tsr_next = tsr_next & ~pwdata;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      reg_tsr <= 8'h00;
    end else begin
      reg_tsr <= tsr_next;
    end
  end

  // ----------------------
  // READ operation
  // ----------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      prdata <= 8'h00;
    end else if ((state == ACCESS) && !pwrite) begin
      case (paddr)
        TDR_ADDR: prdata <= reg_tdr;
        TCR_ADDR: prdata <= reg_tcr;
        TSR_ADDR: prdata <= reg_tsr; 
        default : prdata <= 8'h00;
      endcase
    end
  end

  // ----------------------------------------
  // Ready & Error 
  // ----------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pready  <= 1'b0;
      pslverr <= 1'b0;
    end else begin
      pready  <= (psel && penable);
      pslverr <= (state == ACCESS) && (paddr > 8'h02); // báo lỗi khi ACCESS vào địa chỉ vượt map (0x02)
    end
  end

  // ----------------------
  // Outputs to datapath
  // ----------------------
  assign start_counter = reg_tdr;
  assign load          = reg_tcr[7];
  assign up_down       = reg_tcr[5];
  assign enable        = reg_tcr[4];
  assign clk_sel       = reg_tcr[1:0];

endmodule
