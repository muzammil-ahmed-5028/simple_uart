class apb_uart_tx_smoke_test extends apb_uart_base_test;
    `uvm_component_utils(apb_uart_tx_smoke_test)
    
    function new(string name="apb_uart_tx_smoke_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        apb_custom_sequence cpb_set_seq;
        apb_custom_sequence stp_set_seq;
        apb_custom_sequence rdr_read_seq;
        uart_tx_custom_sequence tx_seq;

        phase.raise_objection(this);
        
        // Setting CPB
        cpb_set_seq = apb_custom_sequence::type_id::create("cpb_set_seq");
        cpb_set_seq.data = 32'd10417;
        cpb_set_seq.addr = 32'h0;
        cpb_set_seq.direction = 1'b1;
        cpb_set_seq.response_required = 1'b0;

        cpb_set_seq.start(env.apb_agent.seqr);
        
        // Setting STP
        stp_set_seq = apb_custom_sequence::type_id::create("stp_set_seq");
        stp_set_seq.data = 2'b00;
        stp_set_seq.addr = 32'h4;
        stp_set_seq.direction = 1'b1;
        stp_set_seq.response_required = 1'b0;

        stp_set_seq.start(env.apb_agent.seqr);
        
        tx_seq = uart_tx_custom_sequence::type_id::create("tx_seq");
        tx_seq.data = 8'h7B;
        tx_seq.inject_framing_error = 1'b0;
        tx_seq.inject_parity_error  = 1'b0;
        tx_seq.start(env.uart_agent_inst.seqr);

        phase.drop_objection(this);

        rdr_read_seq = apb_custom_sequence::type_id::create("rdr_read_seq");
        rdr_read_seq.addr = 32'h8;
        rdr_read_seq.direction = 1'b0;
        rdr_read_seq.response_required = 1'b1;
        rdr_read_seq.start(env.apb_agent.seqr);

    endtask
    
endclass