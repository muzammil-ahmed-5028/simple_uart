class apb_uart_env extends uvm_env;
    `uvm_component_utils(apb_uart_env)

    uart_agent uart_agent_inst;
    uart_cfg    uart_cfg_inst;
    
    apb_master_agent #(32,32) apb_agent;
    UART_CTRL_REGS apb_uart_ral;
    apb_ral_adapter apb_uart_ral_adapter;

    function new(string name="apb_uart_env",uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // UART Agent Configuration
        uart_cfg_inst           = uart_cfg::type_id::create("uart_cfg_inst",this);
        uart_agent_inst         = uart_agent::type_id::create("uart_agent_inst",this);
    
        uart_cfg_inst.parity = PARITY_NONE;
        uart_cfg_inst.stop_length = STOP_PERIOD_1X;
        uart_cfg_inst.data_packet_length = 8;
        uart_cfg_inst.baud_rate = 9600;

        uart_agent_inst.cfg = uart_cfg_inst;
        // APB Agent and Ral Adapter
        apb_agent               = apb_master_agent #(32,32)::type_id::create("apb_agent",this);
        apb_uart_ral_adapter    = apb_ral_adapter::type_id::create("apb_uart_ral_adapter");

        apb_uart_ral            = new("apb_uart_ral");
        apb_uart_ral.build();
        apb_uart_ral.lock_model();
        apb_uart_ral.reset();
        apb_uart_ral.default_map.set_auto_predict(1);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        apb_uart_ral.default_map.set_sequencer(
            apb_agent.seqr,
            apb_uart_ral_adapter
        );

    endfunction
endclass