class apb_transaction;
    rand bit        write;
    rand bit [7:0]  addr;
    rand bit [7:0]  data;

    bit [7:0] rsp_data;
    bit       rsp_err;
    time      sample_time;
    string    name;

    function new(string name = "apb_transaction");
        this.name = name;
    endfunction

    function apb_transaction clone();
        apb_transaction tr = new(name);
        tr.write       = write;
        tr.addr        = addr;
        tr.data        = data;
        tr.rsp_data    = rsp_data;
        tr.rsp_err     = rsp_err;
        tr.sample_time = sample_time;
        return tr;
    endfunction

    function string sprint();
        return $sformatf("%s write=%0b addr=0x%02h data=0x%02h rsp_data=0x%02h rsp_err=%0b",
                         name, write, addr, data, rsp_data, rsp_err);
    endfunction
endclass
