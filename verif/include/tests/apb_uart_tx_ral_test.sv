class apb_uart_tx_ral_test extends apb_uart_base_test;
    `uvm_component_utils(apb_uart_tx_ral_test)
    
    function new(string name="apb_uart_tx_ral_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        uart_tx_custom_sequence tx_seq;
        uvm_status_e ral_status;
        uvm_reg_data_t read_data;

        phase.raise_objection(this);
        
        // Setting CPB
        env.apb_uart_ral.UART_CPB.write(
            ral_status,
            32'd10417,
            UVM_FRONTDOOR,
            env.apb_uart_ral.default_map
        );

        if (ral_status != UVM_IS_OK ) begin
            `uvm_error("RAL_TEST","RAL set of UART_CPB Failed")
        end

        tx_seq = uart_tx_custom_sequence::type_id::create("tx_seq");
        tx_seq.data = 8'h7B;
        tx_seq.inject_framing_error = 1'b0;
        tx_seq.inject_parity_error  = 1'b0;
        tx_seq.start(env.uart_agent_inst.seqr);

        rx_done.wait_trigger();

        env.apb_uart_ral.UART_RDR.read(
            ral_status,
            read_data,
            UVM_FRONTDOOR,
            env.apb_uart_ral.default_map
        );
        
        `uvm_info("RAL TEST",$sformatf("TX_DATA = %0d, RD_DATA from RAL = %0d",tx_seq.data,read_data),UVM_LOW)
        
        phase.drop_objection(this);

    endtask
    
endclass