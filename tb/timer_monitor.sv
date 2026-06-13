class timer_monitor;
    virtual timer_if.tb_mp vif;
    mailbox #(apb_transaction) mon2sb;
    mailbox #(apb_transaction) mon2cov;

    function new(
        virtual timer_if.tb_mp vif,
        mailbox #(apb_transaction) mon2sb,
        mailbox #(apb_transaction) mon2cov
    );
        this.vif    = vif;
        this.mon2sb = mon2sb;
        this.mon2cov= mon2cov;
    endfunction

    task run();
        apb_transaction tr;
        forever begin
            @(posedge vif.clk);
            #1;
            if (vif.rst_n && vif.psel && vif.penable && vif.pready) begin
		@(posedge vif.clk);
            	#1;
                tr = new("mon_tr");
                tr.write       = vif.pwrite;
                tr.addr        = vif.paddr;
                tr.data        = vif.pwdata;
                tr.rsp_data    = vif.prdata;
                tr.rsp_err     = vif.pslverr;
                tr.sample_time = $time;
                mon2sb.put(tr.clone());
                mon2cov.put(tr.clone());
                $display("[%0t][MON] %s", $time, tr.sprint());
            end
        end
    endtask
endclass
