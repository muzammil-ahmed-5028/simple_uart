class apb_uart_rif_smoke_test extends apb_uart_base_test;
    `uvm_component_utils(apb_uart_rif_smoke_test)
    
    function new(string name="apb_uart_rif_smoke_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        apb_write_read_sequence seq;
        
        phase.raise_objection(this);
        
        seq = apb_write_read_sequence::type_id::create("seq");
        seq.start(env.apb_agent.seqr);
        
        phase.drop_objection(this);
    endtask
    
endclass