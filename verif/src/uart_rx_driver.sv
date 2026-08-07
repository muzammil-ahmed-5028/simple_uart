class uart_rx_driver extends uart_base_driver#(uart_seq_item);
    `uvm_component_utils(uart_rx_driver)

    function new(string name="uart_rx_driver",uvm_component parent);
        super.new(name,parent)
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
            
            get_drv_config(
                bit_period,
                stop_period,
                data_packet_length        
            );

            calculate_parity(
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
        end
        
    endtask
endclass