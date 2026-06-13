class apb_driver;
    virtual timer_if.tb_mp vif;
    mailbox #(apb_transaction) stim2drv;

    function new(
        virtual timer_if.tb_mp vif,
        mailbox #(apb_transaction) stim2drv
    );
        this.vif      = vif;
        this.stim2drv = stim2drv;
    endfunction

    task automatic drive_idle();
        vif.psel    <= 1'b0;
        vif.penable <= 1'b0;
        vif.pwrite  <= 1'b0;
        vif.paddr   <= '0;
        vif.pwdata  <= '0;
    endtask

    task automatic apb_write(
        input  bit [7:0] addr,
        input  bit [7:0] data,
        output bit       err
    );
        @(posedge vif.clk);
        vif.psel    <= 1'b1;
        vif.penable <= 1'b0;
        vif.pwrite  <= 1'b1;
        vif.paddr   <= addr;
        vif.pwdata  <= data;

        @(posedge vif.clk);
        vif.penable <= 1'b1;

        do begin
            @(posedge vif.clk);
        end while (!vif.pready);
	@(posedge vif.clk);

        err = vif.pslverr;
        drive_idle();
    endtask

    task automatic apb_read(
        input  bit [7:0] addr,
        output bit [7:0] data,
        output bit       err
    );
        @(posedge vif.clk);
        vif.psel    <= 1'b1;
        vif.penable <= 1'b0;
        vif.pwrite  <= 1'b0;
        vif.paddr   <= addr;
        vif.pwdata  <= '0;

        @(posedge vif.clk);
        vif.penable <= 1'b1;

        do begin
            @(posedge vif.clk);
        end while (!vif.pready);
        @(posedge vif.clk);

        data = vif.prdata;
        err  = vif.pslverr;
        drive_idle();
    endtask

    task run();
        apb_transaction tr;
        bit [7:0] rd;
        bit err;

        drive_idle();
        forever begin
            stim2drv.get(tr);

            @(posedge vif.clk);

            if (tr.write) begin
                apb_write(tr.addr, tr.data, err);
                $display("[%0t][DRV] WRITE addr=0x%02h data=0x%02h err=%0b",
                         $time, tr.addr, tr.data, err);
            end else begin
                apb_read(tr.addr, rd, err);
                $display("[%0t][DRV] READ  addr=0x%02h data=0x%02h err=%0b",
                         $time, tr.addr, rd, err);
            end
        end
    endtask
endclass
