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
        output int      data_packet_length 
    );
        
        bit_period = 1s/cfg.baud_rate;

        case(cfg.stop_length)
            1_STOP_PERIOD   : stop_period = bit_period;
            1_5_STOP_PERIOD : stop_period = bit_period * 1.5;
            2_STOP_PERIOD   : stop_period = bit_period * 2;
            default         : stop_period = bit_period;
        endcase

        data_packet_length = cfg.data_packet_length;

    endfunction

    virtual function calculate_parity(
        input logic [8:0] data,
        input int         data_packet_length,
        output bit        parity_bit,
        output bit        txn_has_parity
    )
        int total_high_bits;
        bit is_odd;

        if (cfg.parity == PARITY_NONE) begin
            parity_bit      = '0;
            txn_has_parity  = '0;
        end
        else begin
            txn_has_parity = '1;

            for (int i=0; i< data_packet_length; i++) begin
                if (data[i] == 1'b1) begin
                    total_high_bits++;
                end
            end

            is_odd = total_high_bits % 2; 
            
            case(cfg.parity)
                PARITY_ODD  : parity_bit = (is_odd) ?  1'b0 : 1'b1;
                PARITY_EVEN : parity_bit = (is_odd) ?  1'b1 : 1'b0;
            endcase

        end
    endfunction

endclass