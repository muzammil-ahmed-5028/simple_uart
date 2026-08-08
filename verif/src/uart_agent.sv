class uart_agent extends uvm_agent;

    uart_tx_driver  drv;
    uart_sequencer  seqr;
    uart_rx_monitor mon;
    virtual uart_if vif;
    uart_cfg        cfg;

    function new(string name="uart_agent", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (cfg == null) begin
            `uvm_fatal("NO_UART_CFG_OBJECT","No uart_cfg object is passed to the Monitor")
        end

        if (!uvm_config_db#(virtual uart_if)::get(
            this,
            "",
            "uart_vif",
            vif)) begin

            `uvm_fatal("NO_UART_VIF","Unable to recieve UART Vif instance")
        end

        drv     = uart_tx_driver::type_id::create("drv",this);
        seqr    = uart_sequencer_driver::type_id::create("seqr",this);
        mon     = uart_rx_monitor::type_id::create("mon", this);

        drv.cfg = cfg;
        mon.cfg = cfg;

        drv.vif = vif;
        mon.vif = vif;

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction 

    
endclass