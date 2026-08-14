class uart_cfg extends uvm_component;
    `uvm_component_utils(uart_cfg)

    rand uart_parity_e               parity;
    rand uart_stop_length_e          stop_length;
    rand int                         data_packet_length;
    rand int unsigned                baud_rate;
    
    constraint c_data_packet_length {
        soft data_packet_lenght inside {[5:9]};
    }
    
    virtual function get_config(
        output realtime bit_period,
        output realtime stop_period,
        output bit      has_parity 
    );
        
        bit_period = 1s/this.baud_rate;

        case(cfg.stop_length)
            1_STOP_PERIOD   : stop_period = bit_period;
            1_5_STOP_PERIOD : stop_period = bit_period * 1.5;
            2_STOP_PERIOD   : stop_period = bit_period * 2;
            default         : stop_period = bit_period;
        endcase

        has_parity = (this.parity == PARITY_NONE) ? 1'b0 : 1'b1;

    endfunction

    virtual function bit calculate_parity(
        input logic [8:0] data,
        output bit        parity_bit
    )
        int total_high_bits;
        bit is_odd;
            
        for (int i=0; i< this.data_packet_length; i++) begin
            if (data[i] == 1'b1) begin
                total_high_bits++;
            end
        end
        
        is_odd = total_high_bits % 2; 
        
        case(cfg.parity)
            PARITY_ODD  : parity_bit = (is_odd) ?  1'b0 : 1'b1;
            PARITY_EVEN : parity_bit = (is_odd) ?  1'b1 : 1'b0;
            default : parity_bit = 1'b0;
        endcase

        
    endfunction

endclass