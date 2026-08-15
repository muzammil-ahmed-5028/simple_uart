class apb_uart_env extends uvm_env;
    `uvm_component_utils(apb_uart_env)

    uart_agent uart_agent_inst;
    apb_master_agent #(32,32) apb_agent;
    uart_cfg    uart_cfg_inst;

    function new(string name="apb_uart_env",uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uart_cfg_inst   = uart_cfg::type_id::create("uart_cfg_inst",this);
        uart_agent_inst = uart_agent::type_id::create("uart_agent_inst",this);
        apb_agent       = apb_master_agent #(32,32)::type_id::create("apb_agent",this);

        uart_cfg_inst.parity = PARITY_NONE;
        uart_cfg_inst.stop_length = STOP_PERIOD_1X;
        uart_cfg_inst.data_packet_length = 8;
        uart_cfg_inst.baud_rate = 9600;

        uart_agent_inst.cfg = uart_cfg_inst;
    endfunction

endclass