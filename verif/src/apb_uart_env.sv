import uart_vip_pkg::*;
import apb_vip_pkg::*;

class apb_uart_env extends uvm_env;
    `uvm_component_utils(apb_uart_env)

    uart_agent uart_agent;
    apb_master_agent #(32,32) apb_agent;

    function new(string name="apb_uart_env",uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uart_agent  = uart_agent::type_id::create("UART_AGENT",this);
        apb_agent   = apb_master_agent #(32,32)::type_id::create("APB_AGENT",this);
    endfunction

endclass