class timer_environment;
    virtual timer_if.tb_mp vif;

    mailbox #(apb_transaction) stim2drv;
    mailbox #(apb_transaction) mon2sb;
    mailbox #(apb_transaction) mon2cov;

    apb_driver       drv;
    timer_monitor    mon;
    timer_stimulus   stim;
    timer_scoreboard sb;
    timer_coverage   cov;

    function new(virtual timer_if.tb_mp vif);
        this.vif = vif;
    endfunction

    function void build();
        stim2drv = new();
        mon2sb   = new();
        mon2cov  = new();

        drv  = new(vif, stim2drv);
        mon  = new(vif, mon2sb, mon2cov);
        stim = new(stim2drv);
        sb   = new(vif, mon2sb);
        cov  = new(mon2cov);
    endfunction

    task start();
        fork
            drv.run();
            mon.run();
            sb.run();
            cov.run();
        join_none
    endtask

    task wait_idle();
        wait (stim2drv.num() == 0);
        repeat (20) @(posedge vif.clk);
    endtask

    function void report();
        sb.report();
        cov.report();
    endfunction
endclass
