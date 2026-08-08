class uart_tx_driver extends uvm_driverr#(uart_seq_item);
    `uvm_component_utils(uart_tx_driver)
    
    virtual uart_if vif;
    uart_cfg cfg;

    function new(string name="uart_tx_driver",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (vif == null) begin
            `uvm_fatal("NO_UART_IF","UART Vif not passed from agent to driver")
        end
        
        if (cfg == null) begin
            `uvm_fatal("NO_UART_CFG","No uart_cfg object is passed to the driver.")
        end

    endfunction
    
    virtual task run_phase(uvm_phase phase);
        uart_seq_item   req;
        realtime        bit_period;
        realtime        stop_period;
        int             data_packet_length;
        bit             has_parity;
        bit             parity_bit;

        forever begin

            vif.tx_o <= 1'b1;
            
            seq_item_port.get_next_item(req);
            
            cfg.get_drv_config(
                bit_period,
                stop_period,
                data_packet_length        
            );

            cfg.calculate_parity(
                req.data,
                data_packet_length,
                parity_bit,
                has_parity
            )

            // 1. Assert Start
            vif.tx_o <= 1'b0;
            #(bit_period);

            // 2. Transmit Data
            for (int i=0; i< data_packet_length; i++) begin
                vif.tx_o <= req.data[i];
                #(bit_period);
            end

            // 3. Send Parity if needed
            if (has_parity) begin
                vif.tx_o <= (inject_parity_error) ? ~parity_bit : parity_bit;                 
                #(bit_period);
            end

            // 4. Send Stop bits 
            vif.tx_o <= inject_framing_error ? 1'b0: 1'b1; 
            #(stop_period);

            seq_item_port.item_done();
        end
        
    endtask
endclass