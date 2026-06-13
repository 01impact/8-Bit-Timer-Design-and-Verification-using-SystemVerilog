class timer_stimulus;
    mailbox #(apb_transaction) stim2drv;
    apb_transaction tr;

    localparam bit [7:0] TDR_ADDR = 8'h00;
    localparam bit [7:0] TCR_ADDR = 8'h01;
    localparam bit [7:0] TSR_ADDR = 8'h02;

    function new(mailbox #(apb_transaction) stim2drv);
        this.stim2drv = stim2drv;
    endfunction

    task send_write(input bit [7:0] addr, input bit [7:0] data);
        tr = new("stim_wr");
        tr.write       = 1'b1;
        tr.addr        = addr;
        tr.data        = data;
        stim2drv.put(tr);
    endtask

    task send_read(input bit [7:0] addr);
        tr = new("stim_rd");
        tr.write       = 1'b0;
        tr.addr        = addr;
        tr.data        = 8'h00;
        stim2drv.put(tr);
    endtask

    task program_load_start(
        input bit [7:0] start_value,
        input bit       up_down,
        input bit       enable,
        input bit [1:0] clk_sel
    );
        bit [7:0] tcr_val;

        tcr_val = {1'b1, 1'b0, up_down, enable, 2'b00, clk_sel};
        send_write(TDR_ADDR, start_value);
        send_write(TCR_ADDR, tcr_val);

        tcr_val[7] = 1'b0;
        send_write(TCR_ADDR, tcr_val);
    endtask

    task gen();
        send_read(TDR_ADDR);
        send_write(TDR_ADDR, 8'hA5);
        send_read(TDR_ADDR);
        send_write(TCR_ADDR, 8'hB1);
        send_read(TCR_ADDR);
        send_write(8'h10, 8'h55);
        send_read(8'h10);
    endtask

    task run();
        gen();
        program_load_start(8'hFE, 1'b1, 1'b1, 2'd0);
    endtask
endclass
