class apb_uart_rif_smoke_test extends apb_uart_base_test;
    `uvm_component_utils(apb_uart_rif_smoke_test)
    
    function new(string name="apb_uart_rif_smoke_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_component phase);
        phase.raise_objection(this);
        
        apb_write_read_sequence seq;
        seq = apb_uart_rif_smoke_test::type_id::create("seq");
        seq.start(env.apb_agent.seqr);
        
        phase.drop_objection(this);
    endtask
    
endclass