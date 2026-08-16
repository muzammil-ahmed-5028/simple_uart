class apb_uart_rx_smoke_test extends apb_uart_base_test;
    `uvm_component_utils(apb_uart_rx_smoke_test)
    
    function new(string name="apb_uart_rx_smoke_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        apb_custom_sequence cpb_set_seq;
        apb_custom_sequence stp_set_seq;
        apb_custom_sequence tdr_set_seq;
        apb_custom_sequence tx_start_seq;
        
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

        //Setting TDR
        tdr_set_seq = apb_custom_sequence::type_id::create("tdr_set_seq");
        tdr_set_seq.data = 8'h7B;
        tdr_set_seq.addr = 32'hC;
        tdr_set_seq.direction = 1'b1;
        tdr_set_seq.response_required = 1'b0;
        tdr_set_seq.start(env.apb_agent.seqr);

        // Starting Tx
        tx_start_seq = apb_custom_sequence::type_id::create("tx_start_seq");
        tx_start_seq.data = 32'h1;
        tx_start_seq.addr = 32'h10;
        tx_start_seq.direction = 1'b1;
        tx_start_seq.response_required = 1'b0;
        tx_start_seq.start(env.apb_agent.seqr);

        tx_done.wait_trigger();

        #(100 * 1ns);
        
        phase.drop_objection(this);

    endtask
    
endclass