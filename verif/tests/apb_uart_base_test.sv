class apb_uart_base_test extends uvm_test;
    `uvm_component_utils(apb_uart_base_test)
    
    apb_uart_env env;

    function new(string name="apb_uart_base_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = apb_uart_env::type_id::create("env",this);
    endfunction
    
endclass